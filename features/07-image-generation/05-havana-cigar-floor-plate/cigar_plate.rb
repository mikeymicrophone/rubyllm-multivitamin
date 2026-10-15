# frozen_string_literal: true

# Image generation · 05 · Havana cigar floor plate
#
# Teaches:
# - provider_options: { output_format: "jpeg" } is merged onto the payload.
# - Image#mime_type is still "image/png" (RubyLLM hardcodes it).
# - to_blob starts with JPEG magic when the provider honored jpeg.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HavanaCigarFloorPlate
  # The ledger clerk at Partagás wants a documentary plate of galera 2
  # as JPEG for the bundle binder, which will not take a PNG.
  class CigarPlate
    PROMPT = <<~TEXT.strip
      Documentary plate of galera 2 on the Partagás rolling floor at 04:10.
      Bundle 3 of 50, wrapper leaf seco, press on the gauges.
      Lot code HAB-14-OCT-26. Overhead industrial light. No people.
    TEXT

    Result = Struct.new(:mime_type, :magic, :base64, keyword_init: true)

    def self.conduct
      configure
      image = RubyLLM.paint(
        PROMPT,
        **Multivitamin::Models.image_paint(provider_options: { output_format: "jpeg" })
      )
      blob = image.to_blob

      Result.new(
        mime_type: image.mime_type,
        magic: blob.byteslice(0, 3),
        base64: image.base64?
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
  Multivitamin::Cassettes.play(__dir__, "cigar_plate") do
    result = HavanaCigarFloorPlate::CigarPlate.conduct
  end

  puts result.mime_type
  puts result.magic.inspect
end
