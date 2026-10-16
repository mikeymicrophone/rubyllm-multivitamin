# frozen_string_literal: true

# Image generation · 01 · Jaipur kite-tissue board
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

module JaipurKiteTissueBoard
  # The kite loft at Johari Bazaar wants a watercolor of the posted
  # tissue-color board before the clerk briefs Farida and Rohan.
  class KiteTissueWatercolor
    PROMPT = <<~TEXT.strip
      Watercolor of the posted tissue-color board at Atelier Rohan, Johari Bazaar, Jaipur, on the eve of Uttarayan.
      Chalked colors: saffron tissue 07:15, 36 sheets; indigo tissue 14:40, 64 sheets.
      The dyer Farida is at the manjha trough.
      Atelier reference: loft card JA-17.
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
  Multivitamin::Cassettes.play(__dir__, "kite_tissue") do
    result = JaipurKiteTissueBoard::KiteTissueWatercolor.conduct
  end

  puts result.model
  puts result.mime_type
end
