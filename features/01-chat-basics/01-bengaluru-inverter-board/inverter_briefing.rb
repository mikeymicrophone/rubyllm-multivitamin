# frozen_string_literal: true

# Chat basics · 01 · Bengaluru inverter board
#
# Teaches:
# - RubyLLM.chat opens a conversation on a named model and provider.
# - with_instructions sets the system prompt, and the next turns keep it.
# - ask sends the transcript and returns a RubyLLM::Message.
# - A second ask on the same chat sends the earlier turns back.
# - finish_reason, tokens, and cost are read off that message.

require_relative "../../../support/runtime"

module BengaluruInverterBoard
  # The Iyer household in Jayanagar reads two questions off the posted
  # inverter board. The clerk's instructions stay on the chat for both.
  class InverterBriefing
    INSTRUCTIONS = <<~TEXT.strip
      You are the household clerk at the Iyer flat in Jayanagar, Bengaluru.
      Brief the morning in short sentences.
      Use only the inverter board in the question.
      Name Lakshmi and the twins.
      Do not invent kilowatt-hour figures.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Inverter board posted for Wednesday 14 October 2026 at the Iyer flat, Jayanagar, Bengaluru.
      Battery 06:42, 0.4 kWh remaining on the Luminous inverter.
      Solar peak 12:18, 8.1 kWh.
      Evening 18:55, 2.6 kWh.
      Lakshmi's washing machine needs 6.0 kWh on the inverter to finish a cotton load.
      The twins Arjun and Meera can charge the Chromebook cart at 3.5 kWh.
      Uncle Ravi is in the puja room for morning aarti until 09:30 and must not be hailed while the lamp is lit.
      When can Lakshmi start the wash this morning, and when can the twins charge?
    TEXT

    AARTI_QUESTION = "The puja room stays closed until 09:30. Should the household hail Uncle Ravi before Lakshmi's wash?"

    Result = Struct.new(
      :opening,
      :follow_up,
      :roles,
      :opening_finish,
      :follow_up_finish,
      :opening_input_tokens,
      :opening_output_tokens,
      :follow_up_input_tokens,
      :follow_up_output_tokens,
      :opening_cost,
      :follow_up_cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      opening = chat.ask(BOARD_QUESTION)
      follow_up = chat.ask(AARTI_QUESTION)

      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        roles: chat.messages.map(&:role),
        opening_finish: opening.finish_reason,
        follow_up_finish: follow_up.finish_reason,
        opening_input_tokens: opening.tokens.input,
        opening_output_tokens: opening.tokens.output,
        follow_up_input_tokens: follow_up.tokens.input,
        follow_up_output_tokens: follow_up.tokens.output,
        opening_cost: opening.cost.total,
        follow_up_cost: follow_up.cost.total
      )
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "inverter_briefing") do
    BengaluruInverterBoard::InverterBriefing.conduct
  end

  puts result.opening
  puts
  puts result.follow_up
end
