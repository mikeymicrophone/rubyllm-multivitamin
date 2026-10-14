# frozen_string_literal: true

# Configuration and contexts · 05 · Friday Harbor key copy
#
# Teaches:
# - Assigning a tenant key on a context does not mutate the global key.
# - The harbormaster still chats on a context that keeps the live key.
# - The unused tenant copy can be read back from context.config.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module FridayHarborKeyCopy
  # The night harbormaster at Friday Harbor keeps the marina's OpenRouter
  # key on a working context and a spare tenant copy that is never sent.
  class KeyCopy
    SPARE_KEY = "friday-harbor-tenant-copy-not-a-live-key"

    INSTRUCTIONS = <<~TEXT.strip
      You are the night harbormaster at the Port of Friday Harbor marina.
      Answer in two short sentences.
      Use only the berth board in the question.
      Name G-14 and Alden.
      Do not invent a berth.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Berth board for Wednesday night 14 October 2026.
      Marina office, 204 Front Street, Friday Harbor, https://www.portfridayharbor.org/.
      G-14 is open and is where Alden should tie, 42 feet, shore power.
      H-2: cannery tender Retort, already tied and staying.
      J-7: closed for piling work, do not assign.
      Where do you put Alden for the night?
    TEXT

    Result = Struct.new(
      :assignment,
      :spare_key,
      :working_key,
      :global_key,
      :spare_matches_global,
      keyword_init: true
    )

    def self.conduct
      configure
      global_key = RubyLLM.config.openrouter_api_key

      spare = RubyLLM.context do |config|
        config.openrouter_api_key = SPARE_KEY
      end

      working = RubyLLM.context do |config|
        config.openrouter_app_name = "Port of Friday Harbor marina"
        config.openrouter_app_url = "https://www.portfridayharbor.org/"
      end
      chat = open_chat(working)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      assignment = chat.ask(BOARD_QUESTION)

      Result.new(
        assignment: assignment.content,
        spare_key: spare.config.openrouter_api_key,
        working_key: working.config.openrouter_api_key,
        global_key: RubyLLM.config.openrouter_api_key,
        spare_matches_global: spare.config.openrouter_api_key == global_key
      )
    end

    def self.open_chat(context)
      ConfigurationPaidOpenrouter.prepare(
        context.chat(**ConfigurationPaidOpenrouter.chat_args)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "key_copy") do
    result = FridayHarborKeyCopy::KeyCopy.conduct
  end

  puts result.assignment
  puts "spare equals global: #{result.spare_matches_global}"
end
