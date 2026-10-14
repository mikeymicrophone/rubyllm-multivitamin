# frozen_string_literal: true

# Tools · 04 · Anacortes retort cook book
#
# Teaches:
# - Pass an instance to with_tools when the tool closes over today's book.
# - parameter :basket, type: :integer declares an integer the model must send.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesRetortCookBook
  # Today's cook book is not a class constant the model can see. The clerk
  # hands the open book to the tool.
  class RetortCookCard < RubyLLM::Tool
    description "Reads one basket from today's retort cook book at the Anacortes cannery"

    def self.tool_name
      "retort_cook_card"
    end

    parameter :basket, type: :integer, description: "Basket number on the morning cook", required: true

    def initialize(cook_book:)
      super()
      @cook_book = cook_book
    end

    def execute(basket:)
      cook = @cook_book[basket.to_i]
      return "No cook card for basket #{basket}." unless cook

      "Basket #{basket.to_i}: #{cook.fetch(:product)} at #{cook.fetch(:temperature_f)} F for #{cook.fetch(:minutes)} minutes, lot #{cook.fetch(:lot)}."
    end
  end

  class MorningCook
    TODAY = {
      3 => { product: "sockeye", temperature_f: 242, minutes: 75, lot: "ANC-1014-B3" }
    }.freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the retort clerk at the Anacortes cannery.
      Call retort_cook_card with the basket number as an integer.
      Answer in one sentence. Include the lot code the tool returns.
    TEXT

    BASKET_QUESTION = <<~TEXT.strip
      Morning cook, Wednesday 14 October 2026, Anacortes cannery.
      The tender ties at https://www.portofanacortes.com/.
      Basket 3 is on the retort. What is that basket's cook?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(RetortCookCard.new(cook_book: TODAY))
      chat.with_tool_options(choice: RetortCookCard)

      answer = chat.ask(BASKET_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content
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
    result = AnacortesRetortCookBook::MorningCook.conduct
  end

  puts result.answer
end
