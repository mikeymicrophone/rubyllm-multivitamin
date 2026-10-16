# frozen_string_literal: true

# Image generation · 03 · Cremona varnish cutaway
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

module CremonaVarnishCutaway
  # The varnish keeper at Atelier Guadagnini wants a cutaway of drawer 3
  # in the cabinet, saved next to the inventory card.
  class VarnishCutaway
    PROMPT = <<~TEXT.strip
      Cutaway drawing of drawer 3 in the varnish cabinet at Atelier Guadagnini, Cremona.
      Spare amber resin, badger brush, and the lake-pigment jar sit in labeled slots.
      The brass label reads Atelier Guadagnini, Piazza Roma, Cremona.
      Technical illustration, overhead lamp, no people.
    TEXT

    Result = Struct.new(:path, :magic, :bytes, :returned_path, keyword_init: true)

    def self.conduct
      configure

      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)
      dir = Dir.mktmpdir("cremona-varnish-")
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
  Multivitamin::Cassettes.play(__dir__, "varnish_cutaway") do
    result = CremonaVarnishCutaway::VarnishCutaway.conduct
  end

  puts result.returned_path
  puts result.magic.inspect
end
