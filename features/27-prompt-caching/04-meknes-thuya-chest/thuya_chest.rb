# frozen_string_literal: true

# Prompt caching · 04 · Meknes thuya chest
#
# Teaches:
# - with_caching(false) stops RubyLLM from sending prompt_cache_options.
# - A provider may still cache implicitly. The request body has no ttl.
# - Passing nil raises ArgumentError; false is the off switch.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MeknesThuyaChest
  class ThuyaChest
    POLICY = (1..24).map { |n|
      "Meknes thuya standing order #{n}: chest #{n} is lot MKN-2026-1016-C#{n}."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the chest clerk in Meknes.
      #{POLICY}
      Answer in one short sentence. Name Fatima and 09:20.
    TEXT

    BOARD = "Board: Fatima oils chest MKN-2026-1016-C1 at 09:20. When does Fatima oil?"

    Result = Struct.new(:brief, :nil_error, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      nil_error = nil
      begin
        chat.with_caching(nil)
      rescue ArgumentError => raised
        nil_error = raised
      end

      chat.with_caching(false)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(BOARD)

      Result.new(brief: brief.content, nil_error: nil_error)
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "thuya_chest") do
    result = MeknesThuyaChest::ThuyaChest.conduct
  end

  puts result.brief
  puts result.nil_error.class
end
