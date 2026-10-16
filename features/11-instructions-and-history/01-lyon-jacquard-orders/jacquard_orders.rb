# frozen_string_literal: true

# Instructions and history · 01 · Lyon Jacquard standing orders
#
# Teaches:
# - with_instructions sets the system prompt.
# - The first chat.messages entry is :system.
# - On OpenAI Responses the clerk's orders ride in instructions, not input.
#   On OpenRouter Chat Completions they are a "role":"system" message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LyonJacquardOrders
  # The floor walker at a Croix-Rousse canut loft posts warp-weight
  # standing orders, then asks when weaver Amélie must be back at the loom.
  class JacquardOrders
    INSTRUCTIONS = <<~TEXT.strip
      You are the floor walker at a Croix-Rousse canut loft in Lyon.
      These are the warp-weight standing orders.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the evening board in the question.
      Name Amélie.
      Do not invent kilogram figures.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Evening board posted for Wednesday 14 October 2026 at the Jacquard loft, Croix-Rousse, Lyon.
      Maison des Canuts: https://www.maisondescanuts.com/
      Warp beam at 12:18, 8.1 kg remaining.
      Warp beam at 18:55, 2.6 kg remaining.
      Weaver Amélie must be back on the bench before the falling beam
      drops through 4.5 kg, or the punch-card chain fouls the comber-board.
      Must Amélie be back on the bench before the 18:55 reading, and is 4.5 kg
      still above that 2.6 kg remainder?
    TEXT

    Result = Struct.new(
      :brief,
      :roles,
      :first_role,
      :first_content,
      :finish,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(BOARD_QUESTION)

      Result.new(
        brief: brief.content,
        roles: chat.messages.map(&:role),
        first_role: chat.messages.first.role,
        first_content: chat.messages.first.content,
        finish: brief.finish_reason,
        input_tokens: brief.tokens.input,
        cost: brief.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "jacquard_orders") do
    result = LyonJacquardOrders::JacquardOrders.conduct
  end

  puts result.brief
end
