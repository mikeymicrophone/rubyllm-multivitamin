# frozen_string_literal: true

# Audio transcription · 08 · Kilisut Harbor diarized watch
#
# Teaches:
# - gpt-4o-transcribe-diarize labels speakers on segments.
# - The default response format is diarized_json.
# - Each segment hash carries speaker, text, start, and end.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KilisutHarborDiarize
  # Two voices share the Kilisut Harbor tape: the weather clerk on the
  # barometer, then the horn tender on visibility.
  class HarborWatch
    RECORDING = File.expand_path("kilisut-harbor-watch.mp3", __dir__)

    Result = Struct.new(:text, :model, :segments, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(
        RECORDING,
        **Multivitamin::Models.transcribe(model: Multivitamin::Models::OPENAI_TRANSCRIBE_DIARIZE)
      )

      Result.new(text: tape.text, model: tape.model, segments: tape.segments)
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
  Multivitamin::Cassettes.play(__dir__, "kilisut_diarize") do
    result = KilisutHarborDiarize::HarborWatch.conduct
  end

  puts result.text
  Array(result.segments).each do |segment|
    puts "#{segment['speaker']}: #{segment['text']}"
  end
end
