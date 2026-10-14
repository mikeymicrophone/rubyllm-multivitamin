# frozen_string_literal: true

# Image generation · 12 · Juan de Fuca chart size refusal
#
# Teaches:
# - size: "256x256" raises RubyLLM::BadRequestError on gpt-image-1-mini.
# - The message lists the sizes the model accepts.
# - The cassette is the 400. There is no image payload to shrink.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaChartSizeRefusal
  # The chart desk asked for a 256-pixel plate of the Juan de Fuca
  # correction. The model refuses that size.
  class ChartSizeRefusal
    PROMPT = <<~TEXT.strip
      Chart table plate of NOAA chart 18465, Strait of Juan de Fuca, with a
      correction in the margin off New Dungeness. Parallel rulers on the table.
      Documentary. No invented buoys.
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
  Multivitamin::Cassettes.play(__dir__, "chart_size_refusal") do
    result = JuanDeFucaChartSizeRefusal::ChartSizeRefusal.conduct
  end

  puts result.error_class
  puts result.message
end
