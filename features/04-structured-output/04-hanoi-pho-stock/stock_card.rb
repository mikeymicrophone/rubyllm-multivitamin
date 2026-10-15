# frozen_string_literal: true

# Structured output · 04 · Hanoi phở stock card
#
# Teaches:
# - Nested objects group the stock, the vessel, and the temperatures.
# - Each nested object has its own required fields.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HanoiPhoStock
  class StockCard < Schematist::Schema
    title "stock_card"
    description "Morning kettle for the Hanoi phở house"

    object :stock, description: "The kettle on the range" do
      string :kettle, description: "Kettle number as written"
      string :bones, description: "What is in the kettle"
      integer :minutes, description: "Simmer minutes"
    end

    object :vessel, description: "Which stockpot is firing" do
      string :name, description: "Stockpot name"
      string :house, description: "Kitchen house"
    end

    object :temperatures, description: "Come-up and simmer, degrees Celsius" do
      integer :come_up_c, description: "Come-up temperature in Celsius"
      integer :simmer_c, description: "Simmer temperature in Celsius"
    end
  end

  class MorningStock
    INSTRUCTIONS = <<~TEXT.strip
      You are the kitchen clerk at a phở house in Hanoi.
      Fill stock_card from the card. Nest stock, vessel, and temperatures.
      Copy the numbers as integers.
    TEXT

    CARD = <<~TEXT.strip
      Hanoi phở house, Wednesday 14 October 2026, morning kettle.
      The house sits on https://whc.unesco.org/en/list/1328
      Kettle 3, oxtail, 90 minutes.
      Vessel: Stockpot No. 2, in the north house.
      Come-up 85 C. Simmer 95 C.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(StockCard)
      answer = chat.ask(CARD)

      Result.new(
        parsed: answer.parsed,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "stock_card") do
    result = HanoiPhoStock::MorningStock.conduct
  end

  puts JSON.generate(result.parsed)
end
