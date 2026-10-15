# frozen_string_literal: true

# Chat basics · 13 · Warsaw tram depot handover across several boards
#
# Teaches:
# - A capstone chat: instructions, two boards in the first ask, a follow-up
#   that needs both, then the readers a relief actually checks.
# - roles, finish_reason, and tokens come off the messages.
# - The follow-up input is larger because the first turn is sent again.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

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

    LOCKER_QUESTION = "The relief asks whether to open the paint locker at first outbound. Answer from both boards."

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

      chat = RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      brief = chat.ask(BOARDS_QUESTION)
      locker = chat.ask(LOCKER_QUESTION)

      Result.new(
        brief: brief.content,
        locker: locker.content,
        roles: chat.messages.map(&:role),
        brief_finish: brief.finish_reason,
        locker_finish: locker.finish_reason,
        brief_input_tokens: brief.tokens.input,
        brief_output_tokens: brief.tokens.output,
        locker_input_tokens: locker.tokens.input,
        locker_output_tokens: locker.tokens.output
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "depot_handover") do
    result = WarsawTramDepot::DepotHandover.conduct
  end

  puts result.brief
  puts
  puts result.locker
end
