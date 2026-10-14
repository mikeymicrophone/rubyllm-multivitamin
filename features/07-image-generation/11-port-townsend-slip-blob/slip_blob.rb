# frozen_string_literal: true

# Image generation · 11 · Port Townsend slip blob
#
# Teaches:
# - Image#to_blob returns the same bytes save writes.
# - Both decode inline Base64. Neither GETs a URL on this model.

require "logger"
require "ruby_llm"
require "tmpdir"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendSlipBlob
  # The slip clerk at Port Townsend writes the crosswind plate to a file
  # and also hands the raw bytes to the printer, and those two must match.
  class SlipBlob
    PROMPT = <<~TEXT.strip
      Port Townsend ferry slip in a 25-knot southeaster on Admiralty Inlet.
      Wind board at the apron reads SE 25. The Khutzeymateen is in the slip.
      Spray on the dolphin. Documentary, no passengers on the apron.
    TEXT

    Result = Struct.new(:blob, :file_bytes, :magic, keyword_init: true)

    def self.conduct
      configure
      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)
      blob = image.to_blob
      path = File.join(Dir.mktmpdir("port-townsend-slip-"), "crosswind.png")
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
  Multivitamin::Cassettes.play(__dir__, "slip_blob") do
    result = PortTownsendSlipBlob::SlipBlob.conduct
  end

  puts result.blob.bytesize
  puts result.blob == result.file_bytes
end
