# frozen_string_literal: true

# Image generation · 06 · Tbilisi sulfur-bath prompt
#
# Teaches:
# - Image#revised_prompt is the provider's rewrite when one is reported.
# - gpt-image-1-mini does not rewrite. revised_prompt is nil.
# - The original prompt is the one on the wire.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TbilisiSulfurBathPrompt
  # The bath desk at Abanotubani wants a blue-hour plate of the brick
  # domes and logs whether the provider rewrote the prompt on the way.
  class SulfurBath
    PROMPT = <<~TEXT.strip
      Abanotubani sulfur baths at blue hour, Tbilisi.
      Bath 4 holds the men's hall; bath 9 is empty for the night fireman.
      Steam on the brick domes. Sodium lamps on the lane.
      Documentary, wet brick, no bathers on the steps.
    TEXT

    Result = Struct.new(:revised_prompt, :original_prompt, :model, keyword_init: true)

    def self.conduct
      configure
      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)

      Result.new(
        revised_prompt: image.revised_prompt,
        original_prompt: PROMPT,
        model: image.model
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
  Multivitamin::Cassettes.play(__dir__, "sulfur_bath") do
    result = TbilisiSulfurBathPrompt::SulfurBath.conduct
  end

  puts result.revised_prompt.inspect
end
