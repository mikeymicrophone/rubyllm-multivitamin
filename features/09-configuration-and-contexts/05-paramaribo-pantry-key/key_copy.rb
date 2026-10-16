# frozen_string_literal: true

# Configuration and contexts · 05 · Paramaribo pantry key copy
#
# Teaches:
# - Assigning a tenant key on a context does not mutate the global key.
# - The household still chats on a context that keeps the live key.
# - The unused tenant copy can be read back from context.config.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module ParamariboPantryKey
  # Auntie Meena's courtyard kitchen in Paramaribo keeps the household
  # OpenRouter key on a working context and a spare pantry copy that is
  # never sent.
  class KeyCopy
    SPARE_KEY = "paramaribo-pantry-copy-not-a-live-key"

    INSTRUCTIONS = <<~TEXT.strip
      You are the evening cook in Auntie Meena's courtyard kitchen in Paramaribo.
      Answer in two short sentences.
      Use only the pantry board in the question.
      Name Meena and C-14.
      Do not invent a shelf.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Pantry board for Wednesday evening 14 October 2026.
      Courtyard kitchen, Combé, Paramaribo.
      Shelf C-14 is open and is where Meena's cassava pot should sit, two Dutch ovens, charcoal ready.
      B-2: already holds the pom for Sunday, do not move.
      A-7: closed for termite work, do not assign.
      Where do you put Meena's cassava pot tonight?
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
        config.openrouter_app_name = "Auntie Meena courtyard kitchen"
        config.openrouter_app_url = "https://www.paramaribo.gov.sr/"
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
    result = ParamariboPantryKey::KeyCopy.conduct
  end

  puts result.assignment
  puts "spare equals global: #{result.spare_matches_global}"
end
