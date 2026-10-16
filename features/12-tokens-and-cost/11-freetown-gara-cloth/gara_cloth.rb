# frozen_string_literal: true

# Tokens and cost · 11 · Freetown gara-cloth harvest tools
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

module FreetownGaraCloth
  # The posted dye card is not in the question. The gara clerk at the
  # Cotton Tree yard has to read it through the tool, then file the
  # yardage. Token counts sit on the final answer and on the chat.
  class PostedGaraCard < RubyLLM::Tool
    description "Reads the gara-cloth dye card posted at the Cotton Tree yard"

    def self.tool_name
      "posted_gara_card"
    end

    CARD = <<~TEXT.strip
      Cotton Tree gara-cloth card for Friday 16 October 2026.
      Bed CT-South, 14 yards, 380 pounds of cloth, cart Lumley alongside at 07:10.
    TEXT

    def execute
      CARD
    end
  end

  class GaraCloth
    INSTRUCTIONS = <<~TEXT.strip
      You are the gara clerk at the Cotton Tree dye yard in Freetown.
      Call posted_gara_card once. Then answer in two short sentences.
      Include the yardage and the cart name from the card.
      Do not invent a pound figure.
    TEXT

    DYE_QUESTION = <<~TEXT.strip
      Morning dye at the Cotton Tree yard, Freetown, Friday 16 October 2026.
      City notes: https://www.fcc.gov.sl/
      Craft board: https://www.visitsierraleone.org/
      The cart is waiting off the Cotton Tree for the bed count and the yardage.
      How many yards, and which cart is alongside?
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
      chat.with_tools(PostedGaraCard)
      chat.with_tool_options(choice: PostedGaraCard)

      answer = chat.ask(DYE_QUESTION)
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
  Multivitamin::Cassettes.play(__dir__, "gara_cloth") do
    result = FreetownGaraCloth::GaraCloth.conduct
  end

  puts result.answer
  puts "answer in=#{result.answer_input} chat in=#{result.chat_input} attempts=#{result.attempts}"
end
