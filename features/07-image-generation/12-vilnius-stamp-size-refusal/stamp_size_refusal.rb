# frozen_string_literal: true

# Image generation · 12 · Vilnius stamp size refusal
#
# Teaches:
# - size: "256x256" raises RubyLLM::BadRequestError on gpt-image-1-mini.
# - The message lists the sizes the model accepts.
# - The cassette is the 400. There is no image payload to shrink.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module VilniusStampSizeRefusal
  # The philatelic desk asked for a 256-pixel plate of the Gediminas
  # Tower issue. The model refuses that size.
  class StampSizeRefusal
    PROMPT = <<~TEXT.strip
      Stamp desk plate of the 1922 Gediminas-Tower issue, Vilnius philatelic bureau, with a
      watermark correction in the margin off the perforation. Tongs on the table.
      Documentary. No invented overprints.
    TEXT

    Result = Struct.new(:error_class, :message, keyword_init: true)

    def self.conduct
      configure
      RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint(size: "256x256"))
      Result.new(error_class: nil, message: nil)
    rescue RubyLLM::BadRequestError => error
      Result.new(error_class: error.class, message: error.message)
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
  Multivitamin::Cassettes.play(__dir__, "stamp_size_refusal") do
    result = VilniusStampSizeRefusal::StampSizeRefusal.conduct
  end

  puts result.error_class
  puts result.message
end
