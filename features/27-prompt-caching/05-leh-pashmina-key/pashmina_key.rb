# frozen_string_literal: true

# Prompt caching · 05 · Leh pashmina key
#
# Teaches:
# - with_caching(key:) sends prompt_cache_key on OpenAI Responses.
# - Gemini CachedContent (id:) needs a key this catalog does not have.
# - The mill names the cache; the provider still decides the hit.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LehPashminaKey
  class PashminaKey
    POLICY = (1..24).map { |n|
      "Leh pashmina standing order #{n}: shawl #{n} is lot LEH-2026-1016-P#{n}."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the shawl clerk in Leh.
      #{POLICY}
      Answer in one short sentence. Name Tsering and 10:05.
    TEXT

    BOARD = "Board: Tsering weighs shawl LEH-2026-1016-P8 at 10:05. When does Tsering weigh?"
    CACHE_KEY = "leh-pashmina-2026-1016"

    Result = Struct.new(:brief, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching(key: CACHE_KEY)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(BOARD)

      Result.new(brief: brief.content)
    end

    def self.configure
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
  Multivitamin::Cassettes.play(__dir__, "pashmina_key") do
    result = LehPashminaKey::PashminaKey.conduct
  end

  puts result.brief
end
