# frozen_string_literal: true

# Chat basics · 11 · Kyoto kimono atelier ticket
#
# Teaches:
# - Two chats, two personas, two with_instructions strings.
# - One persona's transcript grows turn by turn: each say adds a user
#   message and an assistant message.
# - The other persona never sees those later turns.

require_relative "../../../support/runtime"

module KyotoKimonoAtelier
  # Hanae runs the atelier. Aiko is the bride. They read one ticket
  # from two chats, and only Hanae's chat hears the hem grow.
  class KimonoTicket
    DRESSER_INSTRUCTIONS = <<~TEXT.strip
      You are Hanae, the dresser at the kimono atelier on Shinmonzen-dori in Kyoto.
      The street is https://kyoto.travel/.
      Answer in two short sentences.
      Use only ticket KM-214 and the corrections in this chat.
      Name the silk numbers.
      Do not stitch the obi bag.
    TEXT

    BRIDE_INSTRUCTIONS = <<~TEXT.strip
      You are Aiko, the bride commissioning the iro-tomesode.
      Speak as the bride, in two short sentences, telling the atelier what to stitch.
      Use only ticket KM-214.
      The first sentence must contain KM-214.
      Do not mention a millimetre that is not on the ticket.
    TEXT

    TICKET_QUESTION = <<~TEXT.strip
      Alteration ticket KM-214 for Aiko's iro-tomesode, at the Shinmonzen-dori atelier.
      Alteration 1: collar, 14 mm, left shoulder, silk 36.
      Alteration 2: hem, 6 cm, trailing, silk 48.
      The obi bag is not on this ticket.
      Hanae, which alteration do you stitch first, and what silk?
    TEXT

    HEM_QUESTION = <<~TEXT.strip
      Aiko just hailed the atelier.
      The hem grew from 6 cm to 9 cm.
      The collar is unchanged.
      Answer in two sentences.
      The first sentence must contain 9 and silk 48.
      The second sentence must contain silk 36.
    TEXT

    BRIDE_QUESTION = <<~TEXT.strip
      Alteration ticket KM-214 for your iro-tomesode.
      Alteration 1: collar, 14 mm, left shoulder, silk 36.
      Alteration 2: hem, 6 cm, trailing, silk 48.
      Tell the atelier which alteration to stitch first.
    TEXT

    Result = Struct.new(
      :first_stitch,
      :after_the_hail,
      :bride,
      :dresser_lengths,
      :bride_length,
      :dresser_roles,
      :bride_roles,
      :dresser_instructions,
      :bride_instructions,
      :hem_hail_on_the_dresser_chat,
      :hem_hail_on_the_bride_chat,
      keyword_init: true
    )

    def self.conduct
      configure

      dresser = open_chat
      dresser.with_instructions(DRESSER_INSTRUCTIONS)
      dresser.with_temperature(0.2)
      first = dresser.ask(TICKET_QUESTION)
      after_first = dresser.messages.length
      hail = dresser.ask(HEM_QUESTION)
      after_hail = dresser.messages.length

      bride = open_chat
      bride.with_instructions(BRIDE_INSTRUCTIONS)
      bride.with_temperature(0.2)
      bride_reply = bride.ask(BRIDE_QUESTION)

      Result.new(
        first_stitch: first.content,
        after_the_hail: hail.content,
        bride: bride_reply.content,
        dresser_lengths: [after_first, after_hail],
        bride_length: bride.messages.length,
        dresser_roles: dresser.messages.map(&:role),
        bride_roles: bride.messages.map(&:role),
        dresser_instructions: dresser.messages.find { |message| message.role == :system }.content,
        bride_instructions: bride.messages.find { |message| message.role == :system }.content,
        hem_hail_on_the_dresser_chat: dresser.messages.any? { |message|
          message.role == :user && message.content.include?("9 cm")
        },
        hem_hail_on_the_bride_chat: bride.messages.any? { |message|
          message.content.to_s.include?("9 cm")
        }
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "kimono_ticket") do
    KyotoKimonoAtelier::KimonoTicket.conduct
  end

  puts "Hanae, first:"
  puts result.first_stitch
  puts
  puts "Hanae, after the hail (transcript lengths #{result.dresser_lengths.join(" then ")}):"
  puts result.after_the_hail
  puts
  puts "Aiko:"
  puts result.bride
end
