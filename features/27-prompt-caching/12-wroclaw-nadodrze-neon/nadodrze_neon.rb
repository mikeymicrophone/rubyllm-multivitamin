# frozen_string_literal: true

# Prompt caching · 12 · Wrocław Nadodrze neon
#
# Teaches:
# - tokens.cache_write_by_ttl is the Anthropic split. OpenAI omits it.
# - A nil split is not {}. positive_counts drops empty hashes.
# - Read cache_write beside the split.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module WroclawNadodrzeNeon
  class NadodrzeNeon
    POLICY = (1..24).map { |n|
      "Wrocław Nadodrze standing order #{n}: tube #{n} is sign WRO-2026-1016-N#{n}."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the neon clerk in Wrocław.
      #{POLICY}
      Answer in one short sentence from the board only.
      Name Marek and 19:45.
    TEXT

    BOARD = "Board: Marek lights sign WRO-2026-1016-N1 at 19:45. When does Marek light?"

    Result = Struct.new(
      :brief,
      :cache_read,
      :cache_write,
      :cache_write_by_ttl,
      :input_tokens,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching(ttl: "1h")
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(BOARD)

      Result.new(
        brief: brief.content,
        cache_read: brief.tokens.cache_read,
        cache_write: brief.tokens.cache_write,
        cache_write_by_ttl: brief.tokens.cache_write_by_ttl,
        input_tokens: brief.tokens.input
      )
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
  Multivitamin::Cassettes.play(__dir__, "nadodrze_neon") do
    result = WroclawNadodrzeNeon::NadodrzeNeon.conduct
  end

  puts result.brief
  puts "cache_write=#{result.cache_write.inspect} by_ttl=#{result.cache_write_by_ttl.inspect}"
end
