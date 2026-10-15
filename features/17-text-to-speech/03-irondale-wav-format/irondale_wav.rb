# frozen_string_literal: true

# Text to speech · 03 · Irondale WAV format
#
# Teaches:
# - format: "wav" is sent as response_format on the payload.
# - Speech#format is wav and mime_type is audio/wav.
# - save writes RIFF bytes and returns the path.

require "logger"
require "ruby_llm"
require "tmpdir"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module IrondaleWavFormat
  # The mill clerk at Irondale files the pile hail as WAV for the dock
  # recorder, which will not take an MP3.
  class IrondaleWav
    HAIL = "Irondale mill. Tide at the piles."

    Result = Struct.new(:format, :mime_type, :magic, :returned_path, keyword_init: true)

    def self.conduct
      configure
      speech = RubyLLM.speak(HAIL, **Multivitamin::Models.speech(format: "wav"))
      path = File.join(Dir.mktmpdir("irondale-mill-"), "pile_hail.wav")
      returned = speech.save(path)
      bytes = File.binread(path)

      Result.new(
        format: speech.format,
        mime_type: speech.mime_type,
        magic: bytes.byteslice(0, 4),
        returned_path: returned
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
  Multivitamin::Cassettes.play(__dir__, "irondale_wav") do
    result = IrondaleWavFormat::IrondaleWav.conduct
  end

  puts result.format
  puts result.mime_type
  puts result.magic.inspect
end
