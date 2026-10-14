# frozen_string_literal: true

# Image generation · 01 · Point Wilson tide board watercolor
#
# Teaches:
# - RubyLLM.paint returns a RubyLLM::Image.
# - model: and provider: select gpt-image-1-mini on OpenAI.
# - provider_options: { quality: "low" } merges onto the images payload.
# - The Image carries model, mime_type, and the prompt that was sent.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideBoardWatercolor
  # The incoming watch at Point Wilson wants a watercolor of the posted
  # tide board before the clerk briefs Alden and Retort.
  class TideBoardWatercolor
    PROMPT = <<~TEXT.strip
      Watercolor of the Point Wilson Light Station tide board at dusk on Admiralty Inlet.
      Chalked heights: low water 06:42, 0.4 ft above MLLW; high water 12:18, 8.1 ft.
      The foghorn tender Alden is at the kelp-ledge float.
      Station reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Documentary, not decorative. No people.
    TEXT

    Result = Struct.new(:image, :prompt, :model, :mime_type, :base64, keyword_init: true)

    def self.conduct
      configure

      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)

      Result.new(
        image: image,
        prompt: PROMPT,
        model: image.model,
        mime_type: image.mime_type,
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
  Multivitamin::Cassettes.play(__dir__, "tide_board_watercolor") do
    result = PointWilsonTideBoardWatercolor::TideBoardWatercolor.conduct
  end

  puts result.model
  puts result.mime_type
end
