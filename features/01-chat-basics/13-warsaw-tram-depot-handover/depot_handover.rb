# frozen_string_literal: true

# Chat basics · 13 · Warsaw tram depot handover across several boards
#
# Teaches:
# - A capstone chat: instructions, two boards in the first ask, a follow-up
#   that needs both, then the readers a relief actually checks.
# - roles, finish_reason, and tokens come off the messages.
# - The follow-up input is larger because the first turn is sent again.
# - each_with_object builds the handover from named turns and token readers.

require_relative "../../../support/runtime"

module WarsawTramDepot
  # The outgoing dispatcher at Zajezdnia Mokotów hands over the night
  # timetable and the frost card on one chat, then answers the relief's
  # paint-locker question.
  class DepotHandover
    INSTRUCTIONS = <<~TEXT.strip
      You are the outgoing night dispatcher at Zajezdnia Mokotów in Warsaw.
      Brief the overnight relief in short sentences.
      Use only the boards in this chat.
      Name the first outbound time, whether the de-icer is running, and the paint locker.
      Do not invent tram times or spray times.
    TEXT

    BOARDS_QUESTION = <<~TEXT.strip
      Overnight handover at Zajezdnia Mokotów, Wednesday night 14 October 2026.
      Timetable reference: https://www.ztm.waw.pl/.
      Timetable board:
      Last inbound 00:40, line 18.
      First outbound 07:05, line 15.
      Frost card, posted beside the timetable:
      Rails are at -1 C, so the de-icer is running.
      Spray 3 seconds, pause 27 seconds.
      Paint locker: closed. The red oxide is curing. Do not open the locker on this watch.
      Brief the relief. When is first outbound, and is the de-icer running?
    TEXT

    LOCKER_QUESTION = "The relief asks whether to open the paint locker at first outbound. Answer from both boards. Name 07:05 in the answer."

    Result = Struct.new(
      :brief,
      :locker,
      :roles,
      :brief_finish,
      :locker_finish,
      :brief_input_tokens,
      :brief_output_tokens,
      :locker_input_tokens,
      :locker_output_tokens,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      turns = { brief: chat.ask(BOARDS_QUESTION), locker: chat.ask(LOCKER_QUESTION) }
      handover = turns.each_with_object({}) do |(name, message), slate|
        slate[name] = message.content
        slate[:"#{name}_finish"] = message.finish_reason
        %i[input output].each do |direction|
          slate[:"#{name}_#{direction}_tokens"] = message.tokens.public_send(direction)
        end
      end

      Result.new(**handover, roles: chat.map(&:role))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "depot_handover") do
    WarsawTramDepot::DepotHandover.conduct
  end

  puts result.brief
  puts
  puts result.locker
end
