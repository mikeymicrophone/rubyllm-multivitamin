# frozen_string_literal: true

# Prompt caching · 10 · Basel Fasnacht lantern
#
# Teaches:
# - A prefix under the provider minimum still sends prompt_cache_options.
# - tokens.cache_read can be 0. A miss is not an error.
# - Do not pad the standing order just to force a hit.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BaselFasnachtLantern
  class FasnachtLantern
    INSTRUCTIONS = <<~TEXT.strip
      You are the lantern clerk in Basel.
      Answer in one short sentence from the board only.
      Name Elsa and 14:10.
    TEXT

    BOARD = "Board: Elsa hangs lantern BSL-2026-1016-F2 at 14:10. When does Elsa hang?"

    Result = Struct.new(:brief, :cache_read, :input_tokens, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching(ttl: "5m")
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(BOARD)

      Result.new(
        brief: brief.content,
        cache_read: brief.tokens.cache_read,
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
  Multivitamin::Cassettes.play(__dir__, "fasnacht_lantern") do
    result = BaselFasnachtLantern::FasnachtLantern.conduct
  end

  puts result.brief
  puts "cache_read=#{result.cache_read.inspect} input=#{result.input_tokens}"
end
