# frozen_string_literal: true

# Text to speech · 09 · Fort Flagler tokens and cost
#
# Teaches:
# - Speech#tokens.input and tokens.output are nil on tts-1.
# - Speech#cost.total is nil. The response is raw audio, not JSON usage.
# - That is not the same as a free chat model's cost of 0.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FortFlaglerTokensCost
  # The park clerk at Fort Flagler wants the radio card spoken, then
  # records usage on the work order the way a chat turn would.
  class FlaglerCost
    HAIL = "Fort Flagler. Tokens on the card."

    Result = Struct.new(
      :input_tokens,
      :output_tokens,
      :cost_total,
      :cost_input,
      :cost_output,
      :model,
      keyword_init: true
    )

    def self.conduct
      configure
      speech = RubyLLM.speak(HAIL, **Multivitamin::Models.speech)

      Result.new(
        input_tokens: speech.tokens.input,
        output_tokens: speech.tokens.output,
        cost_total: speech.cost.total,
        cost_input: speech.cost.input,
        cost_output: speech.cost.output,
        model: speech.model
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "flagler_cost") do
    result = FortFlaglerTokensCost::FlaglerCost.conduct
  end

  puts "tokens #{result.input_tokens.inspect}/#{result.output_tokens.inspect} cost #{result.cost_total.inspect}"
end
