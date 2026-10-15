# frozen_string_literal: true

# Image generation · 02 · Seoul ondol flue size
#
# Teaches:
# - size: is sent on the images/generations payload for OpenAI.
# - gpt-image-1-mini accepts 1024x1024, 1024x1536, 1536x1024, and auto.
# - The smallest of those, 1024x1024, is the bottled default.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SeoulOndolFlueSize
  class OndolFlueSize
    PROMPT = <<~TEXT.strip
      Square documentary plate of the ondol flue at Hanok 14, Bukchon-ro, Seoul.
      The flue cap stands above the kitchen ondol. Rain on the clay stack.
      Ondol survey reference for Bukchon, not a postcard.
      No people, no courtyard invented beyond the flue.
    TEXT

    Result = Struct.new(:image, :size_on_wire, keyword_init: true)

    def self.conduct
      configure
      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint(size: "1024x1024"))
      Result.new(image: image, size_on_wire: "1024x1024")
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
  Multivitamin::Cassettes.play(__dir__, "ondol_flue_size") do
    result = SeoulOndolFlueSize::OndolFlueSize.conduct
  end
  puts result.image.model
  puts result.size_on_wire
end
