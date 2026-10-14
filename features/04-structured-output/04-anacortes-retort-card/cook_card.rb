# frozen_string_literal: true

# Structured output · 04 · Anacortes retort card
#
# Teaches:
# - Nested objects group the cook, the vessel, and the temperatures.
# - Each nested object has its own required fields.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesRetortCard
  class CookCard < Schematist::Schema
    title "cook_card"
    description "Morning cook for the Anacortes cannery retort"

    object :cook, description: "The basket in the retort" do
      string :basket, description: "Basket number as written"
      string :product, description: "What is in the basket"
      integer :minutes, description: "Process minutes"
    end

    object :vessel, description: "Which retort is firing" do
      string :name, description: "Retort name"
      string :house, description: "Cannery house"
    end

    object :temperatures, description: "Come-up and process, degrees Fahrenheit" do
      integer :come_up_f, description: "Come-up temperature in Fahrenheit"
      integer :process_f, description: "Process temperature in Fahrenheit"
    end
  end

  class MorningCook
    INSTRUCTIONS = <<~TEXT.strip
      You are the cannery clerk at Anacortes.
      Fill cook_card from the card. Nest cook, vessel, and temperatures.
      Copy the numbers as integers.
    TEXT

    CARD = <<~TEXT.strip
      Anacortes cannery, Wednesday 14 October 2026, morning cook.
      The tender ties at https://www.portofanacortes.com/.
      Basket 3, sockeye, 90 minutes.
      Vessel: Retort No. 2, in the north house.
      Come-up 230 F. Process 250 F.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(CookCard)
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
  Multivitamin::Cassettes.play(__dir__, "cook_card") do
    result = AnacortesRetortCard::MorningCook.conduct
  end

  puts JSON.generate(result.parsed)
end
