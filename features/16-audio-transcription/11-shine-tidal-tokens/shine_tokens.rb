# frozen_string_literal: true

# Audio transcription · 11 · Shine Tidal tokens
#
# Teaches:
# - Transcription#tokens reads usage the way a chat message does.
# - cost.total is the priced total, or nil when the registry has no audio
#   rate and the response omits a reported cost.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ShineTidalTokens
  # The bridge tender at Shine Tidal files the Hood Canal opening tape and
  # records the token counts on the work order beside the barge name.
  class BridgeTape
    RECORDING = File.expand_path("shine-tidal-bridge.mp3", __dir__)

    Result = Struct.new(
      :text,
      :model,
      :duration,
      :input_tokens,
      :output_tokens,
      :cost_total,
      keyword_init: true
    )

    def self.conduct
      configure
      tape = RubyLLM.transcribe(RECORDING, **Multivitamin::Models.transcribe)

      Result.new(
        text: tape.text,
        model: tape.model,
        duration: tape.duration,
        input_tokens: tape.tokens.input,
        output_tokens: tape.tokens.output,
        cost_total: tape.cost.total
      )
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
  Multivitamin::Cassettes.play(__dir__, "shine_tokens") do
    result = ShineTidalTokens::BridgeTape.conduct
  end

  puts "duration #{result.duration} tokens #{result.input_tokens.inspect}/#{result.output_tokens.inspect} cost #{result.cost_total.inspect}"
  puts result.text
end
