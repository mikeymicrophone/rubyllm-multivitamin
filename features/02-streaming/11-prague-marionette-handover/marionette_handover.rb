# frozen_string_literal: true

# Streaming · 11 · Prague marionette handover
#
# Teaches:
# - Two streamed asks share one chat.
# - The second request carries the first answer in input.
#   gpt-4.1-mini does not send reasoning_details.

require_relative "../../../support/runtime"

module PragueMarionetteHandover
  # The outgoing stage manager at the National Marionette Theatre speaks
  # the morning boards, then answers the relief's question about the fly
  # loft. Both answers are streamed.
  class MarionetteHandover
    INSTRUCTIONS = <<~TEXT.strip
      You are the outgoing stage manager at the National Marionette Theatre in Prague.
      Brief the morning relief in short sentences.
      Use only the boards in this chat.
      Name the rehearsal call 07:05 and whether the house PA is running.
      Do not invent a curtain time.
    TEXT

    BOARDS_QUESTION = <<~TEXT.strip
      Overnight handover at the National Marionette Theatre, Prague, Wednesday night 14 October 2026.
      House notes: https://www.narodni-divadlo.cz/en
      Call board: rehearsal 07:05, Don Giovanni on the small stage.
      House PA card: the loop is live. Cue 3 seconds, rest 27 seconds.
      Fly loft: closed. The working lamp is burning. Do not open the loft on this watch.
      Speak the brief. When is rehearsal, and is the house PA running?
    TEXT

    LOFT_QUESTION = "The relief asks whether to open the fly loft at rehearsal. Answer from both boards."

    Result = Struct.new(
      :brief,
      :cabinet,
      :brief_pieces,
      :cabinet_pieces,
      :roles,
      :brief_finish,
      :cabinet_finish,
      :brief_input_tokens,
      :cabinet_input_tokens,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      brief_pieces = []
      brief = chat.ask(BOARDS_QUESTION) { |chunk| keep(brief_pieces, chunk) }
      cabinet_pieces = []
      cabinet = chat.ask(LOFT_QUESTION) { |chunk| keep(cabinet_pieces, chunk) }

      Result.new(
        brief: brief.content,
        cabinet: cabinet.content,
        brief_pieces: brief_pieces,
        cabinet_pieces: cabinet_pieces,
        roles: chat.messages.map(&:role),
        brief_finish: brief.finish_reason,
        cabinet_finish: cabinet.finish_reason,
        brief_input_tokens: brief.tokens.input,
        cabinet_input_tokens: cabinet.tokens.input
      )
    end

    def self.keep(pieces, chunk)
      piece = chunk.content.to_s
      pieces << piece unless piece.empty?
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "marionette_handover") do
    PragueMarionetteHandover::MarionetteHandover.conduct
  end

  puts result.brief
  puts
  puts result.cabinet
end
