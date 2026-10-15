# frozen_string_literal: true

# Text to speech · 10 · Rat Island mime_type
#
# Teaches:
# - Speech#mime_type follows format:, not the HTTP Content-Type header.
# - mp3 is audio/mpeg. wav is audio/wav.
# - Both clips stay on tts-1.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RatIslandMimeType
  # The channel watch between Rat Island and Indian Island files the same
  # hail as MP3 for the VHF desk and as WAV for the recorder.
  class RatMime
    HAIL = "Rat Island. Mime on the wire."

    Result = Struct.new(:mp3_mime, :wav_mime, :mp3_format, :wav_format, :mp3_magic, :wav_magic, keyword_init: true)

    def self.conduct
      configure
      mp3 = RubyLLM.speak(HAIL, **Multivitamin::Models.speech)
      wav = RubyLLM.speak(HAIL, **Multivitamin::Models.speech(format: "wav"))

      Result.new(
        mp3_mime: mp3.mime_type,
        wav_mime: wav.mime_type,
        mp3_format: mp3.format,
        wav_format: wav.format,
        mp3_magic: mp3.to_blob.getbyte(0),
        wav_magic: wav.to_blob.byteslice(0, 4)
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
  Multivitamin::Cassettes.play(__dir__, "rat_mime") do
    result = RatIslandMimeType::RatMime.conduct
  end

  puts "#{result.mp3_format} #{result.mp3_mime}"
  puts "#{result.wav_format} #{result.wav_mime}"
end
