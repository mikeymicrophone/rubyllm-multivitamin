# frozen_string_literal: true

# Audio transcription · 09 · Indian Island known-speaker clips
#
# Teaches:
# - speaker_names: and speaker_references: identify known voices.
# - References are short clips of Alden and Calder, two to ten seconds.
# - The request sends known_speaker_names and known_speaker_references.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module IndianIslandSpeakers
  # The ammunition-pier watch at Indian Island files a two-voice tape and
  # hands the desk reference clips of Alden and Calder so the labels match
  # the standing watch bill.
  class KnownVoices
    RECORDING = File.expand_path("indian-island-watch.mp3", __dir__)
    ALDEN = File.expand_path("alden-reference.mp3", __dir__)
    CALDER = File.expand_path("calder-reference.mp3", __dir__)
    NAMES = %w[Alden Calder].freeze

    Result = Struct.new(:text, :model, :segments, :speakers, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(
        RECORDING,
        **Multivitamin::Models.transcribe(model: Multivitamin::Models::OPENAI_TRANSCRIBE_DIARIZE),
        speaker_names: NAMES,
        speaker_references: [ALDEN, CALDER]
      )
      speakers = Array(tape.segments).map { |segment| segment["speaker"] || segment[:speaker] }.compact

      Result.new(text: tape.text, model: tape.model, segments: tape.segments, speakers: speakers)
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
  Multivitamin::Cassettes.play(__dir__, "indian_speakers") do
    result = IndianIslandSpeakers::KnownVoices.conduct
  end

  puts result.speakers.inspect
  puts result.text
end
