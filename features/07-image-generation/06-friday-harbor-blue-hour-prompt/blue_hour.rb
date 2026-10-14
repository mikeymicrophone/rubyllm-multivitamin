# frozen_string_literal: true

# Image generation · 06 · Friday Harbor blue hour prompt
#
# Teaches:
# - Image#revised_prompt is the provider's rewrite when one is reported.
# - gpt-image-1-mini does not rewrite. revised_prompt is nil.
# - The original prompt is the one on the wire.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborBlueHourPrompt
  # The berth desk at Friday Harbor wants a blue-hour plate of the floats
  # and logs whether the provider rewrote the prompt on the way.
  class BlueHour
    PROMPT = <<~TEXT.strip
      Friday Harbor floats at blue hour, San Juan Channel.
      Slip 14 holds the packet Orcas, slip 9 is empty for the mail boat.
      Tide 6.2 ft at the outer float. Sodium lamps on the finger piers.
      Documentary, wet planks, no passengers on the floats.
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
  Multivitamin::Cassettes.play(__dir__, "blue_hour") do
    result = FridayHarborBlueHourPrompt::BlueHour.conduct
  end

  puts result.revised_prompt.inspect
end
