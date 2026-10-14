# frozen_string_literal: true

# Chat basics · 13 · Overnight watch handover across several boards
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

module PointWilsonNightWatch
  # The outgoing watch at Point Wilson hands over the night tide board and
  # the foghorn card on one chat, then answers the relief's cabinet question.
  class WatchHandover
    INSTRUCTIONS = <<~TEXT.strip
      You are the outgoing tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Brief the overnight relief in short sentences.
      Use only the boards in this chat.
      Name the low water time, whether the horn is running, and the lens cabinet.
      Do not invent tide heights or blast times.
    TEXT

    BOARDS_QUESTION = <<~TEXT.strip
      Overnight handover at Point Wilson, Wednesday night 14 October 2026.
      Tide reference: https://tidesandcurrents.noaa.gov/ station 9444900.
      Tide board:
      High water 00:40, 7.6 ft above MLLW.
      Low water 07:05, 1.1 ft.
      Foghorn card, posted beside the tide board:
      Visibility is 1 mile, so the horn is running.
      Blast 3 seconds, silent 27 seconds.
      Lens cabinet: closed. The lamp is burning. Do not open the cabinet on this watch.
      Brief the relief. When is low water, and is the horn running?
    TEXT

    CABINET_QUESTION = "The relief asks whether to open the lens cabinet at low water. Answer from both boards."

    Result = Struct.new(
      :brief,
      :cabinet,
      :roles,
      :brief_finish,
      :cabinet_finish,
      :brief_input_tokens,
      :brief_output_tokens,
      :cabinet_input_tokens,
      :cabinet_output_tokens,
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
      cabinet = chat.ask(CABINET_QUESTION)

      Result.new(
        brief: brief.content,
        cabinet: cabinet.content,
        roles: chat.messages.map(&:role),
        brief_finish: brief.finish_reason,
        cabinet_finish: cabinet.finish_reason,
        brief_input_tokens: brief.tokens.input,
        brief_output_tokens: brief.tokens.output,
        cabinet_input_tokens: cabinet.tokens.input,
        cabinet_output_tokens: cabinet.tokens.output
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
  Multivitamin::Cassettes.play(__dir__, "watch_handover") do
    result = PointWilsonNightWatch::WatchHandover.conduct
  end

  puts result.brief
  puts
  puts result.cabinet
end
