# frozen_string_literal: true

# Image generation · 03 · New Dungeness lens cutaway
#
# Teaches:
# - Image#save writes bytes from inline data and returns the path.
# - The file's magic bytes are PNG on this model at default output_format.
# - save does not open a second HTTP call when base64? is true.

require "logger"
require "ruby_llm"
require "tmpdir"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NewDungenessLensCutaway
  # The lens keeper at New Dungeness wants a cutaway of drawer 3 in the
  # cabinet, saved next to the inventory card.
  class LensCutaway
    PROMPT = <<~TEXT.strip
      Cutaway drawing of drawer 3 in the New Dungeness Fresnel lens cabinet.
      Spare lamp, wick scissors, and the red sector shade sit in labeled slots.
      The brass label reads New Dungeness Light Station, Strait of Juan de Fuca.
      Technical illustration, overhead lamp, no people.
    TEXT

    Result = Struct.new(:path, :magic, :bytes, :returned_path, keyword_init: true)

    def self.conduct
      configure

      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)
      dir = Dir.mktmpdir("new-dungeness-lens-")
      path = File.join(dir, "drawer3_cutaway.png")
      returned = image.save(path)
      bytes = File.binread(path)

      Result.new(
        path: path,
        returned_path: returned,
        magic: bytes.byteslice(0, 8),
        bytes: bytes.bytesize
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
  Multivitamin::Cassettes.play(__dir__, "lens_cutaway") do
    result = NewDungenessLensCutaway::LensCutaway.conduct
  end

  puts result.returned_path
  puts result.magic.inspect
end
