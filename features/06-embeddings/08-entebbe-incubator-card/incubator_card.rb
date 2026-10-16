# frozen_string_literal: true

# Embeddings · 08 · Entebbe incubator plaque
#
# Teaches:
# - with: sends an image beside one text on a multimodal embedding model.
# - OpenRouter wraps that as a content array of text and image_url.
# - OpenAI text-embedding-3-small raises UnsupportedAttachmentError
#   before any HTTP call.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EntebbeIncubatorCard
  # The night clerk at UVRI embeds the photographed incubator plaque with a
  # one-line caption so a later query can retrieve the falling reading.
  class IncubatorCard
    PLAQUE = File.expand_path("incubator-plaque.png", __dir__)
    CAPTION = "Entebbe UVRI incubator plaque, Wednesday 14 October 2026, 37.4 C, falling."
    VISION_MODEL = "google/gemini-embedding-2"
    CARD_WIDTH = 768

    Result = Struct.new(
      :vectors,
      :model_id,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure_openrouter
      embedding = RubyLLM.embed(
        CAPTION,
        model: VISION_MODEL,
        provider: :openrouter,
        assume_model_exists: true,
        with: PLAQUE,
        dimensions: CARD_WIDTH
      )

      Result.new(
        vectors: embedding.vectors,
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.configure_openrouter
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end

    def self.configure_openai
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "incubator_card") do
    result = EntebbeIncubatorCard::IncubatorCard.conduct
  end

  puts "#{result.model_id} #{result.vectors.length} dimensions"
end
