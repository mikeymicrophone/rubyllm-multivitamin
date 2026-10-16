# frozen_string_literal: true

# Prompt caching · 01 · Kairouan chechia felt
#
# Teaches:
# - with_caching turns on provider prompt caching with no extra options.
# - OpenAI automatic caching sends no prompt_cache_options unless ttl,
#   key, or mode is set.
# - Keep the standing order at the front of the chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KairouanChechiaFelt
  class ChechiaFelt
    POLICY = (1..36).map { |n|
      "Kairouan chechia standing order #{n}: rack #{n} holds cap KAI-2026-1016-C#{n}, " \
        "felt at #{format('%02d', (n % 12) + 1)}:10, do not mix the carded wool with the nap."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the felt clerk at a chechia workshop in Kairouan.
      #{POLICY}
      Answer in one short sentence from the board only.
      Name Hamza and 08:25.
    TEXT

    BOARD = "Board: Hamza starts cap KAI-2026-1016-C3 at 08:25. When does Hamza start?"
    FOLLOW = "Does the standing order allow mixing the carded wool with the nap? Answer No or Yes."

    Result = Struct.new(:opening, :follow_up, :roles, :cache_read, :input_tokens, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      opening = chat.ask(BOARD)
      follow_up = chat.ask(FOLLOW)

      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        roles: chat.messages.map(&:role),
        cache_read: follow_up.tokens.cache_read,
        input_tokens: follow_up.tokens.input
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
  Multivitamin::Cassettes.play(__dir__, "chechia_felt") do
    result = KairouanChechiaFelt::ChechiaFelt.conduct
  end

  puts result.opening
  puts result.follow_up
  puts "cache_read=#{result.cache_read.inspect} input=#{result.input_tokens}"
end
