# frozen_string_literal: true

# Tools · 01 · Addis Ababa coffee-auction chalkboard
#
# Teaches:
# - A RubyLLM::Tool subclass has a description and an execute method.
# - with_tools registers the class. RubyLLM 2.1.1 has no with_tool.
# - self.tool_name keeps a short name. A nested class would otherwise
#   keep the module, with :: written as --.
# - execute with no keywords returns a String. That string is the :tool
#   message, and the final answer is where the board shows up.

require_relative "../../../support/runtime"

module AddisAbabaAuctionBoard
  # The posted chalkboard is not in the question. The clerk has to read it
  # through the tool, then tell the floor when the lots can be presented.
  class PostedLotBoard < RubyLLM::Tool
    description "Reads the coffee-auction chalkboard posted at the ECX floor in Addis Ababa for the morning session"

    def self.tool_name
      "posted_lot_board"
    end

    BOARD = <<~TEXT.strip
      ECX auction chalkboard for Thursday 15 October 2026, Addis Ababa.
      Yirgacheffe washed Grade 2 sample, 06:42, 0.4 bags remaining.
      Sidamo natural Grade 4 sample, 12:18, 8.1 bags.
      Halima presents the Yirgacheffe at 10:46.
      Tadesse can use the cupping table at 08:57.
    TEXT

    def execute
      BOARD
    end
  end

  class AuctionWindow
    INSTRUCTIONS = <<~TEXT.strip
      You are the floor clerk at the Ethiopia Commodity Exchange in Addis Ababa.
      Call posted_lot_board once. Then answer in two short sentences.
      Include the clock times the board gives for Halima and for Tadesse.
      Do not invent a bag count.
    TEXT

    WINDOW_QUESTION = <<~TEXT.strip
      Morning session at the ECX floor, Thursday 15 October 2026.
      Auction notes: https://www.ecx.com.et/
      Lot clerk Halima and cupper Tadesse are both at the sample table.
      When can each of them work this morning?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(PostedLotBoard)
      chat.with_tool_options(choice: PostedLotBoard)

      answer = chat.ask(WINDOW_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "auction_board") do
    AddisAbabaAuctionBoard::AuctionWindow.conduct
  end

  puts result.answer
end
