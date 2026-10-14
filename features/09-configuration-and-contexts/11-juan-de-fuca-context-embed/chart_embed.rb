# frozen_string_literal: true

# Configuration and contexts · 11 · Juan de Fuca context embed
#
# Teaches:
# - ctx.embed uses the context's key and endpoint.
# - RubyLLM.embed uses the global key and endpoint.
# - Authorization on the two cassette interactions comes from different
#   providers.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaContextEmbed
  # The mate correcting NOAA chart 18465 embeds the Dungeness Spit notice
  # twice: once through a Strait context on OpenRouter, once through the
  # global OpenAI desk.
  class ChartEmbed
    NOTICE = <<~TEXT.strip
      Correction slip JC-18465 for NOAA chart 18465, Strait of Juan de Fuca.
      Chart catalog: https://www.nauticalcharts.noaa.gov/.
      Dungeness Spit lighted bell buoy DH is moved 300 yards northwest of
      the symbol printed on the chart. The old symbol is still printed.
    TEXT

    Result = Struct.new(
      :context_width,
      :global_width,
      :context_model,
      :global_model,
      :context_title,
      :global_title,
      keyword_init: true
    )

    def self.conduct
      configure
      strait = RubyLLM.context do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.openrouter_app_name = "Juan de Fuca chart desk"
        config.openrouter_app_url = "https://www.nauticalcharts.noaa.gov/"
        config.default_embedding_model = Multivitamin::Models::EMBEDDING_TEXT
      end

      context_embedding = strait.embed(
        NOTICE,
        model: Multivitamin::Models::EMBEDDING_TEXT,
        provider: :openrouter,
        assume_model_exists: true
      )
      global_embedding = RubyLLM.embed(
        NOTICE,
        model: Multivitamin::Models::OPENAI_EMBEDDING,
        provider: :openai
      )

      Result.new(
        context_width: context_embedding.vectors.length,
        global_width: global_embedding.vectors.length,
        context_model: context_embedding.model,
        global_model: global_embedding.model,
        context_title: strait.config.openrouter_app_name,
        global_title: RubyLLM.config.openrouter_app_name
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "chart_embed") do
    result = JuanDeFucaContextEmbed::ChartEmbed.conduct
  end

  puts "context #{result.context_model} #{result.context_width}"
  puts "global #{result.global_model} #{result.global_width}"
end
