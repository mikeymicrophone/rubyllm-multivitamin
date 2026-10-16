# frozen_string_literal: true

# Chat basics · 08 · Johannesburg clinic vitals round
#
# Teaches:
# - An instance owns the round's chat; a Data record carries its stopped? flag.
# - The check is the finish reason, not a search through the prose for "stop".
# - A factual clipboard is a single ask with instructions to copy, not forecast.

require_relative "../../../support/runtime"

module JohannesburgClinicVitals
  # Sister Nomsa at the Alexandra municipal clinic reads the clipboard back.
  # The round is done when the message stopped, whatever the sentences say.
  class VitalsRound
    INSTRUCTIONS = <<~TEXT.strip
      You are Sister Nomsa at the municipal clinic in Alexandra, Johannesburg.
      Read the vitals round back in four short sentences, one fact each.
      Use only the clipboard in the question.
      Do not forecast tomorrow and do not add a reading that is not written.
      Include the pulse, the temperature, the blood pressure, and the oxygen.
    TEXT

    ROUND_QUESTION = <<~TEXT.strip
      Morning vitals round, Alexandra clinic, Wednesday 14 October 2026, 06:00.
      The sister may later compare the clipboard with https://www.who.int/.
      This round is the clipboard, not the ward feed:
      Pulse: 72 bpm.
      Temperature: 36.8 C.
      Blood pressure: 118/76.
      Oxygen: 98 percent.
      Patient: Thabo Mokoena.
      Read the round back for the log.
    TEXT

    Result = Data.define(:round, :stopped, :finish_reason, :roles)

    attr_reader :chat

    def self.conduct = new.conduct

    def initialize
      self.class.configure
      @chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
                     .with_instructions(INSTRUCTIONS)
                     .with_temperature(0.2)
    end

    def conduct
      reply = chat.ask(ROUND_QUESTION)

      Result.new(
        round: reply.content,
        stopped: reply.stopped?,
        finish_reason: reply.finish_reason,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "vitals_round") do
    JohannesburgClinicVitals::VitalsRound.conduct
  end

  puts result.round
  puts
  puts "stopped=#{result.stopped} finish=#{result.finish_reason}"
end
