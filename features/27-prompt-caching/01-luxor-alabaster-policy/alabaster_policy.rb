# frozen_string_literal: true

# Prompt caching · 01 · Luxor alabaster policy
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

module LuxorAlabasterPolicy
  class AlabasterPolicy
    POLICY = (1..36).map { |n|
      "Luxor alabaster standing order #{n}: rack #{n} holds block LXR-2026-1016-A#{n}, " \
        "weigh at #{format('%02d', (n % 12) + 1)}:10, do not mix the Nile silt with the calcite."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the mill clerk at an alabaster workshop in Luxor.
      #{POLICY}
      Answer in one short sentence from the board only.
      Name Nour and 07:15.
    TEXT

    BOARD = "Board: Nour starts block LXR-2026-1016-A3 at 07:15. When does Nour start?"
    FOLLOW = "Does the standing order allow mixing Nile silt with the calcite? Answer No or Yes."

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
  Multivitamin::Cassettes.play(__dir__, "alabaster_policy") do
    result = LuxorAlabasterPolicy::AlabasterPolicy.conduct
  end

  puts result.opening
  puts result.follow_up
  puts "cache_read=#{result.cache_read.inspect} input=#{result.input_tokens}"
end
