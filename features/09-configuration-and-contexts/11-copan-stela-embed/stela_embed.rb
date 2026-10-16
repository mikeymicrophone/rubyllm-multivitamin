# frozen_string_literal: true

# Configuration and contexts · 11 · Copán stela context embed
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
require_relative "../paid_openrouter"

module CopanStelaEmbed
  # The epigrapher correcting Stela 3 embeds the glyph-row notice
  # twice: once through a park context on OpenRouter, once through the
  # global OpenAI desk.
  class StelaEmbed
    NOTICE = <<~TEXT.strip
      Correction slip CP-ST3 for Copán Stela 3, Great Plaza.
      Park listing: https://whc.unesco.org/en/list/129.
      The glyph at row 8, block B is moved one column west of the
      rubbing printed in the 1970s catalog. The old rubbing is still filed.
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
      park = RubyLLM.context do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.openrouter_app_name = "Copán epigraphy desk"
        config.openrouter_app_url = "https://whc.unesco.org/en/list/129"
        config.default_embedding_model = ConfigurationPaidOpenrouter.embed_args.fetch(:model)
      end

      context_embedding = park.embed(NOTICE, **ConfigurationPaidOpenrouter.embed_args)
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
        context_title: park.config.openrouter_app_name,
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
  Multivitamin::Cassettes.play(__dir__, "stela_embed") do
    result = CopanStelaEmbed::StelaEmbed.conduct
  end

  puts "context #{result.context_model} #{result.context_width}"
  puts "global #{result.global_model} #{result.global_width}"
end
