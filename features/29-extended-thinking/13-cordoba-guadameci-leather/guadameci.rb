# frozen_string_literal: true

# Extended thinking · 13 · Córdoba guadamecí leather
#
# Teaches:
# - A summarized thinking turn, then a follow-up, keeps the signature
#   on the first assistant message.
# - tokens.thinking is present on both asks.
# - The standing order still answers No on the second turn.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CordobaGuadameciLeather
  class GuadameciLeather
    POLICY = (1..8).map { |n|
      "Córdoba guadamecí standing order #{n}: hide #{n} is lot COR-2026-1016-L#{n}."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the guadamecí clerk in Córdoba.
      #{POLICY}
      Answer in one short sentence from the board only.
      Name Rafael and 08:55.
      Do not mix the tooled hide with the gilt.
    TEXT

    BOARD = "Board: Rafael tools hide COR-2026-1016-L4 at 08:55. When does Rafael tool?"
    FOLLOW = "Does the standing order allow mixing the tooled hide with the gilt? Answer No or Yes."

    Result = Struct.new(
      :opening,
      :follow_up,
      :opening_thinking,
      :opening_signature,
      :opening_tokens,
      :follow_tokens,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_REASONING, provider: :openai)
      chat.with_thinking(effort: :low, display: :summarized)
      chat.with_instructions(INSTRUCTIONS)
      opening = chat.ask(BOARD)
      follow_up = chat.ask(FOLLOW)
      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        opening_thinking: opening.thinking&.text,
        opening_signature: opening.thinking&.signature,
        opening_tokens: opening.tokens.thinking,
        follow_tokens: follow_up.tokens.thinking,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "guadameci") do
    result = CordobaGuadameciLeather::GuadameciLeather.conduct
  end

  puts result.opening
  puts result.follow_up
end
