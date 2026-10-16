# frozen_string_literal: true

# Tools · 04 · Porto lodge cask book
#
# Teaches:
# - Pass an instance to with_tools when the tool closes over today's book.
# - parameter :cask, type: :integer declares an integer the model must send.
# - case/in unpacks a complete card and handles a missing entry explicitly.

require_relative "../../../support/runtime"

module PortoLodgeCask
  # Today's lodge book is not a class constant the model can see. The clerk
  # hands the open book to the tool.
  class LodgeCaskCard < RubyLLM::Tool
    description "Reads one cask from today's lodge book at a Vila Nova de Gaia port lodge"

    def self.tool_name
      "lodge_cask_card"
    end

    parameter :cask, type: :integer, description: "Cask number on the morning lodge round", required: true

    def initialize(lodge_book:)
      super()
      @lodge_book = lodge_book
    end

    def execute(cask:)
      case @lodge_book[cask.to_i]
      in { variety:, humidity_pct:, months:, lot: }
        "Cask #{cask.to_i}: #{variety} at #{humidity_pct} percent humidity for #{months} months, lot #{lot}."
      in nil
        "No lodge card for cask #{cask}."
      else
        raise KeyError, "Incomplete lodge card for cask #{cask}."
      end
    end
  end

  class MorningLodge
    TODAY = {
      3 => { variety: "touriga-nacional", humidity_pct: 82, months: 24, lot: "PRT-1014-C3" }
    }.freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the lodge clerk at Taylor's in Vila Nova de Gaia, Porto.
      Call lodge_cask_card with the cask number as an integer.
      Answer in one sentence. Include the lot code the tool returns.
    TEXT

    CASK_QUESTION = <<~TEXT.strip
      Morning lodge round, Thursday 15 October 2026, Vila Nova de Gaia.
      Lodge notes: https://www.ivdp.pt/
      Cask 3 is on the rack. What is that cask's rest?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(LodgeCaskCard.new(lodge_book: TODAY))
      chat.with_tool_options(choice: LodgeCaskCard)

      answer = chat.ask(CASK_QUESTION)
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

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "cask_card") do
    PortoLodgeCask::MorningLodge.conduct
  end

  puts result.answer
end
