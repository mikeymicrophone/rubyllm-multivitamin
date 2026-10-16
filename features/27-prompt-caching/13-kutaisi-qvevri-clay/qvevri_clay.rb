# frozen_string_literal: true

# Prompt caching · 13 · Kutaisi qvevri clay
#
# Teaches:
# - Capstone: ttl, key, an explicit breakpoint, and a second ask.
# - cache_read on the follow-up is an Integer. Zero is legal.
# - The cassette is two Responses POSTs.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KutaisiQvevriClay
  class QvevriClay
    POLICY = (1..36).map { |n|
      "Kutaisi qvevri standing order #{n}: pit #{n} holds jar KUT-2026-1016-Q#{n}, " \
        "seal with beeswax, do not mix Rkatsiteli with Saperavi."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the qvevri clerk in Kutaisi.
      #{POLICY}
      Answer in one short sentence from the board only.
      Name Nino and 16:20.
    TEXT

    BOARD = "Board: Nino seals jar KUT-2026-1016-Q6 at 16:20. When does Nino seal?"
    FOLLOW = "Does the standing order allow mixing Rkatsiteli with Saperavi? Answer No or Yes."
    CACHE_KEY = "kutaisi-qvevri-2026-1016"

    Result = Struct.new(
      :opening,
      :follow_up,
      :cache_read,
      :cache_write,
      :roles,
      :input_tokens,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching(ttl: "1h", key: CACHE_KEY, mode: "explicit")
      chat.with_instructions(INSTRUCTIONS).cache_until_here(ttl: "1h")
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      opening = chat.ask(BOARD)
      follow_up = chat.ask(FOLLOW)

      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        cache_read: follow_up.tokens.cache_read,
        cache_write: follow_up.tokens.cache_write,
        roles: chat.messages.map(&:role),
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
  Multivitamin::Cassettes.play(__dir__, "qvevri_clay") do
    result = KutaisiQvevriClay::QvevriClay.conduct
  end

  puts result.opening
  puts result.follow_up
  puts "cache_read=#{result.cache_read.inspect}"
end
