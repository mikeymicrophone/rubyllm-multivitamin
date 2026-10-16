# frozen_string_literal: true

# Image generation · 11 · Chiang Mai umbrella blob
#
# Teaches:
# - Image#to_blob returns the same bytes save writes.
# - Both decode inline Base64. Neither GETs a URL on this model.

require "logger"
require "ruby_llm"
require "tmpdir"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ChiangMaiUmbrellaBlob
  # The workshop clerk at Bo Sang writes the lotus-umbrella plate to a
  # file and also hands the raw bytes to the woodblock printer, and those
  # two must match.
  class UmbrellaBlob
    PROMPT = <<~TEXT.strip
      Bo Sang paper-umbrella workshop, Chiang Mai, in a southwest monsoon.
      Drying-line tag reads SW 25. Lotus umbrella UM-14 is on the rack.
      Lacquer spray on the bamboo rib. Documentary, no tourists on the bench.
    TEXT

    Result = Struct.new(:blob, :file_bytes, :magic, keyword_init: true)

    def self.conduct
      configure
      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)
      blob = image.to_blob
      path = File.join(Dir.mktmpdir("chiang-mai-umbrella-"), "lotus.png")
      image.save(path)

      Result.new(
        blob: blob,
        file_bytes: File.binread(path),
        magic: blob.byteslice(0, 8)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "umbrella_blob") do
    result = ChiangMaiUmbrellaBlob::UmbrellaBlob.conduct
  end

  puts result.blob.bytesize
  puts result.blob == result.file_bytes
end
