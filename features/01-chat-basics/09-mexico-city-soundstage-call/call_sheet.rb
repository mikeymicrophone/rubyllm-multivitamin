# frozen_string_literal: true

# Chat basics · 09 · Mexico City soundstage call sheet
#
# Teaches:
# - Reusing a chat keeps the call sheet, so a short follow-up still works.
# - A fresh chat that only hears the follow-up does not have the sheet.
# - The same question string is a different job once the transcript changes.
# - A RubyLLM.context isolates configuration; OpenRouter receives a seed override.

require_relative "../../../support/runtime"

module MexicoCitySoundstage
  # The second AD at Estudios Churubusco answers "And the Patio unit?" twice:
  # once on the chat that already has the call sheet, and once on a
  # new chat that was never shown the board.
  class CallSheet
    INSTRUCTIONS = <<~TEXT.strip
      You are the second AD at Estudios Churubusco in Mexico City.
      Answer in one or two short sentences from the call sheet in this conversation.
      If this conversation has never included a posted call sheet, reply with
      exactly this sentence and nothing else:
      The call sheet was not handed over.
      Do not invent setup times.
    TEXT

    SHEET_QUESTION = <<~TEXT.strip
      Call sheet posted at Estudios Churubusco for Wednesday 14 October 2026.
      The studio page is https://www.estudioschurubusco.com/.
      Stage opens 06:30.
      First setup 09:15 for the song number Monzón del Palacio.
      Stage closes 11:40.
      Afternoon setup 15:05 for the dialogue unit Patio de los Naranjos.
      When is first setup for Monzón del Palacio?
    TEXT

    PATIO_QUESTION = "And the Patio de los Naranjos unit?"

    Result = Struct.new(
      :monzon,
      :patio_on_the_same_chat,
      :patio_on_a_fresh_chat,
      :reused_roles,
      :fresh_roles,
      :fresh_user_text,
      :reused_still_has_sheet,
      keyword_init: true
    )

    def self.conduct
      studio = RubyLLM.context do |config|
        Multivitamin::Runtime.apply(config, provider: :openrouter)
      end
      reused = open_chat(studio)
      monzon = reused.ask(SHEET_QUESTION)
      patio_same = reused.ask(PATIO_QUESTION)

      fresh = open_chat(studio)
      patio_fresh = fresh.ask(PATIO_QUESTION)

      Result.new(
        monzon: monzon.content,
        patio_on_the_same_chat: patio_same.content,
        patio_on_a_fresh_chat: patio_fresh.content,
        reused_roles: reused.messages.map(&:role),
        fresh_roles: fresh.messages.map(&:role),
        fresh_user_text: fresh.messages.find { |message| message.role == :user }.content,
        reused_still_has_sheet: reused.messages.any? { |message|
          message.role == :user && message.content.include?("Monzón del Palacio")
        }
      )
    end

    def self.open_chat(studio)
      options = Multivitamin::Models.chat(provider: :openrouter)
      model, provider = options.values_at(:model, :provider)
      chat = studio.chat(model:, provider:, assume_model_exists: provider == :openrouter)
                   .with_instructions(INSTRUCTIONS)
                   .with_temperature(0.2)
      chat.with_provider_options(seed: 1014) if provider == :openrouter
      Multivitamin::Models.quiet_thinking(chat, provider: :openrouter)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "call_sheet") do
    MexicoCitySoundstage::CallSheet.conduct
  end

  puts result.monzon
  puts
  puts "same chat: #{result.patio_on_the_same_chat}"
  puts
  puts "fresh chat: #{result.patio_on_a_fresh_chat}"
end
