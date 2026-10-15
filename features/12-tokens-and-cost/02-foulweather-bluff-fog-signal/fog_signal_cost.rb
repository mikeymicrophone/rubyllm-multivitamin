# frozen_string_literal: true

# Tokens and cost · 02 · Foulweather Bluff fog-signal zero
#
# Teaches:
# - A free slug reports usage.cost 0, and cost.total is that 0.
# - A reported zero is not nil. Missing prices would have been nil.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FoulweatherBluffFogSignal
  # The keeper at Foulweather Bluff reads the posted fog-signal card,
  # then files the cost of that hail. The free clerk reports zero.
  class FogSignalCost
    INSTRUCTIONS = <<~TEXT.strip
      You are the keeper at Foulweather Bluff Light, north of Hood Canal.
      Answer in two short sentences.
      Use only the fog-signal card in the question.
      Name the 4-second blast and the 16-second silent.
      Do not invent a compressor figure.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Fog-signal card at Foulweather Bluff, Wednesday 14 October 2026, 05:50.
      Light list: https://www.navcen.uscg.gov/
      Visibility 0.6 mile in the haze over Admiralty Inlet.
      Horn running. Blast 4 seconds, silent 16 seconds.
      The tender Osprey is standing in toward Twin Spits and needs the pattern.
      Speak the pattern for the log.
    TEXT

    Result = Struct.new(
      :brief,
      :cost_total,
      :reported_cost,
      :cost_is_nil,
      :input_tokens,
      :output_tokens,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(CARD_QUESTION)

      Result.new(
        brief: brief.content,
        cost_total: brief.cost.total,
        reported_cost: brief.tokens.reported_cost,
        cost_is_nil: brief.cost.total.nil?,
        input_tokens: brief.tokens.input,
        output_tokens: brief.tokens.output
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
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
  Multivitamin::Cassettes.play(__dir__, "fog_signal_cost") do
    result = FoulweatherBluffFogSignal::FogSignalCost.conduct
  end

  puts result.brief
  puts "cost=#{result.cost_total.inspect} reported=#{result.reported_cost.inspect} nil?=#{result.cost_is_nil}"
end
