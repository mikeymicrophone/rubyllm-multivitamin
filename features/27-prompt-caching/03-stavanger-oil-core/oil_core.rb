# frozen_string_literal: true

# Prompt caching · 03 · Stavanger oil core
#
# Teaches:
# - cache_until_here marks the instructions as an explicit breakpoint.
# - gpt-4.1-mini answers HTTP 400: prompt_cache_breakpoint is not supported.
# - Empty with_caching still enables automatic caching; the mark is extra.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module StavangerOilCore
  class OilCore
    POLICY = (1..24).map { |n|
      "Stavanger core standing order #{n}: tray #{n} holds core SVG-2026-1016-C#{n}, fridge at 4 C."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the core clerk in Stavanger.
      #{POLICY}
      Answer in one short sentence from the tray card only.
      Name Sigrid and 06:50.
    TEXT

    CARD = "Tray card: Sigrid logs core SVG-2026-1016-C4 at 06:50. When does Sigrid log?"

    Result = Struct.new(:error, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching
      chat.with_instructions(INSTRUCTIONS).cache_until_here
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      error = nil
      begin
        chat.ask(CARD)
      rescue RubyLLM::BadRequestError => raised
        error = raised
      end

      Result.new(error: error)
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
  Multivitamin::Cassettes.play(__dir__, "oil_core") do
    result = StavangerOilCore::OilCore.conduct
  end

  puts result.error.class
  puts result.error.message
end
