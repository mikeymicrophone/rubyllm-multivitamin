# frozen_string_literal: true

# Tokens and cost · 11 · Cattle Point bull-kelp harvest tools
#
# Teaches:
# - A forced tool round still reports input and output tokens on the
#   final answer.
# - chat.tokens includes the tool-call attempt, not only the spoken turn.
# - cost.total is still the provider's reported number.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CattlePointBullKelp
  # The posted harvest card is not in the question. The kelp clerk at
  # Cattle Point has to read it through the tool, then file the sack
  # count. Token counts sit on the final answer and on the chat.
  class PostedKelpCard < RubyLLM::Tool
    description "Reads the bull-kelp harvest card posted at Cattle Point"

    def self.tool_name
      "posted_kelp_card"
    end

    CARD = <<~TEXT.strip
      Cattle Point bull-kelp card for Wednesday 14 October 2026.
      Bed CP-South, 14 sacks, 380 pounds, skiff Haro alongside at 07:10.
    TEXT

    def execute
      CARD
    end
  end

  class BullKelp
    INSTRUCTIONS = <<~TEXT.strip
      You are the kelp clerk at Cattle Point, southeast San Juan Island.
      Call posted_kelp_card once. Then answer in two short sentences.
      Include the sack count and the skiff name from the card.
      Do not invent a pound figure.
    TEXT

    HARVEST_QUESTION = <<~TEXT.strip
      Morning harvest at Cattle Point, Wednesday 14 October 2026.
      Light list: https://www.navcen.uscg.gov/
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      The skiff is waiting off the Cattle Point light for the bed count.
      How many sacks, and which skiff is alongside?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_contents,
      :answer_input,
      :answer_output,
      :answer_cost,
      :chat_input,
      :chat_output,
      :chat_cost,
      :attempts,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openrouter)
      chat.with_tools(PostedKelpCard)
      chat.with_tool_options(choice: PostedKelpCard)

      answer = chat.ask(HARVEST_QUESTION)
      tool_contents = chat.messages.select { |message| message.role == :tool }.map(&:content)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_contents: tool_contents,
        answer_input: answer.tokens.input,
        answer_output: answer.tokens.output,
        answer_cost: answer.cost.total,
        chat_input: chat.tokens.input,
        chat_output: chat.tokens.output,
        chat_cost: chat.cost.total,
        attempts: chat.usage_entries.size
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "bull_kelp") do
    result = CattlePointBullKelp::BullKelp.conduct
  end

  puts result.answer
  puts "answer in=#{result.answer_input} chat in=#{result.chat_input} attempts=#{result.attempts}"
end
