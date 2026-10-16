# frozen_string_literal: true

# Streaming · 04 · Angkor stone-join steps
#
# Teaches:
# - Ordered steps stay in order when a chunk ends mid-sentence.
# - The message returned after streaming is the assistant turn.
# - Message callbacks bracket a stream collected by a named lambda.

require_relative "../../../support/runtime"

module AngkorStoneJoin
  class InspectionTape
    attr_reader :pieces, :events

    def initialize
      @pieces = []
      @events = []
    end

    def start = events << :started
    def finish(message) = events << message.role

    def append(chunk)
      text = chunk.content.to_s
      pieces << text unless text.empty?
    end
  end

  # The conservator at Angkor Wat calls the stone-join inspection in the
  # order the card lists it: laterite core, sandstone facing, iron cramps,
  # lime mortar.
  class StoneJoin
    INSTRUCTIONS = <<~TEXT.strip
      You are the conservator on the west gallery at Angkor Wat.
      Call the four stone-join checks in the order given, one short sentence each.
      Use only the inspection card.
      Keep the four names in that order: laterite core, sandstone facing, iron cramps, lime mortar.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Stone-join inspection for Wednesday 14 October 2026, west gallery, Angkor Wat, Siem Reap.
      Conservation notes: https://whc.unesco.org/en/list/668/
      1. Laterite core is dry, both faces, and the joints are packed.
      2. Sandstone facing is sound, with no cracked course in the lower four.
      3. Iron cramps are fitted on the fifth course and sit square.
      4. Lime mortar runs the full length and the mason can bed it.
      Call the four checks in that order.
    TEXT

    Result = Struct.new(
      :speech,
      :pieces,
      :same_message,
      :role,
      :roles,
      :finish_reason,
      :stopped,
      :events,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      tape = InspectionTape.new
      chat.before_message(&tape.method(:start))
      chat.after_message(&tape.method(:finish))
      printer = ->(chunk) { tape.append(chunk) }
      message = chat.ask(CARD_QUESTION, &printer)

      Result.new(
        speech: message.content,
        pieces: tape.pieces,
        same_message: chat.messages.last.equal?(message),
        role: message.role,
        roles: chat.messages.map(&:role),
        finish_reason: message.finish_reason,
        stopped: message.stopped?,
        events: tape.events
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "stone_join") do
    AngkorStoneJoin::StoneJoin.conduct
  end

  puts result.speech
end
