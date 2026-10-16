# frozen_string_literal: true

# Chat basics · 03 · Chronometer timing card at La Chaux-de-Fonds
#
# Teaches:
# - with_temperature set very low, because a timing card must not be embellished.
# - with_instructions tells the watchmaker to stay on the card.
# - A short reply is still a full RubyLLM::Message.
# - Fluent configuration and an immutable Data value keep the slate compact.

require_relative "../../../support/runtime"

module ChauxDeFondsChronometer
  # The watchmaker copies the posted timing card onto the bench slate.
  # Extra sentences would put the wrong beat on the regulator.
  class TimingCard
    INSTRUCTIONS = <<~TEXT.strip
      You are the watchmaker at the regulating bench in La Chaux-de-Fonds.
      Copy the timing card in three lines and then stop.
      Use only the card in the question.
      Do not describe the museum, the Jura landscape, or the town tour.
      Line 1 must be "Beat: 18000 bph".
      Line 2 must be "Amplitude: 270 degrees".
      Line 3 must be "Escapement: Swiss lever".
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Timing card posted on the regulating bench in La Chaux-de-Fonds.
      The museum is the Musée international d'horlogerie, https://www.mih.ch/.
      The card, not the museum brochure, is what the watchmaker copies:
      Beat 18000 bph.
      Amplitude 270 degrees.
      The escapement is the Swiss lever, not the cylinder and not the detent.
      Characteristic repeats for as long as the watch stays on the regulator.
      Write the three-line slate.
    TEXT

    Result = Data.define(:card, :temperature, :finish_reason, :roles)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
                   .with_instructions(INSTRUCTIONS)
                   .with_temperature(0.0)

      reply = chat.ask(CARD_QUESTION)

      Result.new(
        card: reply.content,
        temperature: chat.temperature,
        finish_reason: reply.finish_reason,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "timing_card") do
    ChauxDeFondsChronometer::TimingCard.conduct
  end

  puts result.card
  puts
  puts "temperature=#{result.temperature.inspect} finish=#{result.finish_reason} chars=#{result.card.to_s.length}"
end
