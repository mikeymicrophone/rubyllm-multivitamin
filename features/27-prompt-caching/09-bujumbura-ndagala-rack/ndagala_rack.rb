# frozen_string_literal: true

# Prompt caching · 09 · Bujumbura ndagala rack
#
# Teaches:
# - with_caching(mode: "implicit") still sends prompt_cache_options.mode.
# - gpt-4.1-mini answers HTTP 400: prompt_cache_options is not supported.
# - Slot 03 used cache_until_here; this slot is the mode option.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BujumburaNdagalaRack
  class NdagalaRack
    POLICY = (1..24).map { |n|
      "Bujumbura ndagala standing order #{n}: rack #{n} holds lot BJM-2026-1016-N#{n}."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the rack clerk in Bujumbura.
      #{POLICY}
      Answer in one short sentence from the card only.
      Name Aline and 05:55.
    TEXT

    CARD = "Rack card: Aline turns lot BJM-2026-1016-N4 at 05:55. When does Aline turn?"

    Result = Struct.new(:error, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching(mode: "implicit")
      chat.with_instructions(INSTRUCTIONS)
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
  Multivitamin::Cassettes.play(__dir__, "ndagala_rack") do
    result = BujumburaNdagalaRack::NdagalaRack.conduct
  end

  puts result.error.class
  puts result.error.message
end
