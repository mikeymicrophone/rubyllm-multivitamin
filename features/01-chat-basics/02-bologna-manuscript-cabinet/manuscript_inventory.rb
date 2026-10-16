# frozen_string_literal: true

# Chat basics · 02 · Bologna manuscript cabinet
#
# Teaches:
# - One RubyLLM.chat, one ask, one RubyLLM::Message back.
# - content, role, and model (the id string) are read off that message.
# - tokens.input and tokens.output are the counts for this turn.
# - finish_reason says why the model stopped.

require_relative "../../../support/runtime"

module BolognaManuscriptCabinet
  # The relief librarian at the Archiginnasio counts one cabinet. The
  # question is a single ask, and the whole lesson is what the message gives back.
  class ManuscriptInventory
    INSTRUCTIONS = <<~TEXT.strip
      You are the manuscript librarian at the Archiginnasio in Bologna.
      Answer in two short sentences.
      Use only the cabinet list in the question.
      Quote catalog marks exactly as printed.
      Do not invent drawers, folios, or cradles.
    TEXT

    CABINET_QUESTION = <<~TEXT.strip
      Cabinet list posted in the manuscript room at the Archiginnasio, Bologna.
      The reading-room log is kept for https://www.archiginnasio.it/ and the
      statute this drawer marks is listed on https://www.bub.unibo.it/.
      Drawer A: fourteenth-century statute fragment, cracked binding, catalog AS-4, do not issue.
      Drawer B: spare vellum folio, catalog VF-17.
      Drawer C: six book cradles, catalog BC-6.
      Drawer D: lectern chain, catalog CL-2, seized and waiting on a pin.
      Which drawer holds the spare vellum folio, and how many cradles are in drawer C?
      Quote both catalog marks.
    TEXT

    Result = Struct.new(
      :content,
      :role,
      :model_id,
      :chat_model_id,
      :finish_reason,
      :input_tokens,
      :output_tokens,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      reply = chat.ask(CABINET_QUESTION)

      Result.new(
        content: reply.content,
        role: reply.role,
        model_id: reply.model,
        chat_model_id: chat.model.id,
        finish_reason: reply.finish_reason,
        input_tokens: reply.tokens.input,
        output_tokens: reply.tokens.output,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "manuscript_inventory") do
    BolognaManuscriptCabinet::ManuscriptInventory.conduct
  end

  puts result.content
  puts
  puts "role=#{result.role} model=#{result.model_id} finish=#{result.finish_reason} " \
       "tokens=#{result.input_tokens}/#{result.output_tokens}"
end
