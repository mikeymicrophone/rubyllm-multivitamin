# frozen_string_literal: true

# Prompt caching · 07 · Palembang songket
#
# Teaches:
# - A second ask on the same chat can report tokens.cache_read.
# - Zero is a legal miss. The field is an Integer, not omitted.
# - Keep the standing order at the front on both turns.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PalembangSongket
  class Songket
    POLICY = (1..36).map { |n|
      "Palembang songket standing order #{n}: loom #{n} holds cloth PLB-2026-1016-S#{n}, " \
        "gold thread faces the Musi, do not mix the supplemental weft with the ground."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the loom clerk in Palembang.
      #{POLICY}
      Answer in one short sentence from the board only.
      Name Wati and 11:30.
    TEXT

    BOARD = "Board: Wati starts cloth PLB-2026-1016-S5 at 11:30. When does Wati start?"
    FOLLOW = "Does the standing order allow mixing the supplemental weft with the ground? Answer No or Yes."

    Result = Struct.new(
      :opening,
      :follow_up,
      :cache_read,
      :cache_write,
      :input_tokens,
      :roles,
      keyword_init: true
    )

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
        cache_read: follow_up.tokens.cache_read,
        cache_write: follow_up.tokens.cache_write,
        input_tokens: follow_up.tokens.input,
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "songket") do
    result = PalembangSongket::Songket.conduct
  end

  puts result.opening
  puts result.follow_up
  puts "cache_read=#{result.cache_read.inspect} cache_write=#{result.cache_write.inspect}"
end
