# frozen_string_literal: true

# Tools · 07 · Bogotá emerald parcel
#
# Teaches:
# - A miss returns { error: }. That hash is JSON on the tool message,
#   and the model can call the tool again.
# - choice: :required is cleared after the tool runs, so the second call
#   is the model's own.

require_relative "../../../support/runtime"

module BogotaEmeraldParcel
  class EmeraldParcel < RubyLLM::Tool
    description "Reads the parcel card for an emerald lot on the Muzo desk in Bogotá"

    def self.tool_name
      "emerald_parcel"
    end

    parameter :parcel, type: :string, description: "Parcel name on the desk, such as CO-4", required: true

    CARDS = {
      "CO-4" => "CO-4 parcel 12.6 ct at the Muzo desk, read Thursday 15 October 2026."
    }.freeze

    def execute(parcel:)
      card = CARDS[parcel.to_s.upcase]
      return card if card

      { error: "#{parcel} is not on the Muzo desk. Call emerald_parcel again with parcel CO-4." }
    end
  end

  class ParcelRound
    INSTRUCTIONS = <<~TEXT.strip
      You are the parcel clerk at the Muzo desk in Bogotá.
      Call emerald_parcel with the parcel the floor named.
      If the tool returns an error, call emerald_parcel again with the parcel the error names.
      Then answer in one sentence that includes the carat weight from the card.
    TEXT

    PARCEL_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, parcel round at the Muzo desk in Bogotá.
      Trade notes: https://www.fedesmeraldas.org/
      The floor asked for the card on parcel CO-17.
      Read the card and report the carat weight.
    TEXT

    Result = Struct.new(:answer, :roles, :tool_contents, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(EmeraldParcel)
      chat.with_tool_options(choice: :required)

      answer = chat.ask(PARCEL_QUESTION)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "emerald_parcel") do
    BogotaEmeraldParcel::ParcelRound.conduct
  end

  puts result.answer
end
