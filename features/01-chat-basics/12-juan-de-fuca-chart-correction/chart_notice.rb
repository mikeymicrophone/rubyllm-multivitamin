# frozen_string_literal: true

# Chat basics · 12 · Chart correction for the Strait of Juan de Fuca
#
# Teaches:
# - A tight with_max_output_tokens can come back empty or too short to post.
# - The clerk reads content and max_tokens? before trusting the note.
# - response.raw.status is the HTTP status beside the parsed message.
# - When the note is too short, a second ask on the same chat asks for
#   the correction in full, with the cap cleared.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaChart
  # The mate's correction slip for chart 18465 is long enough to post.
  # The first ask is capped so the note may come back clipped. The clerk
  # only posts a note that has room to name the chart and the buoy.
  class ChartNotice
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate correcting NOAA chart 18465 on the Strait of Juan de Fuca.
      Use only the correction slip in this chat.
      Name chart 18465 and buoy DH.
      Do not invent a latitude or a longitude.
    TEXT

    SLIP_QUESTION = <<~TEXT.strip
      Correction slip JC-18465, copied for the watch on Wednesday 14 October 2026.
      Chart catalog: https://www.nauticalcharts.noaa.gov/.
      Notice desk the mate copied from: https://www.navcen.uscg.gov/.
      NOAA chart 18465, Strait of Juan de Fuca.
      Dungeness Spit lighted bell buoy DH is moved 300 yards northwest of the symbol printed on the chart.
      The old symbol is still printed. Do not use it for a fix.
      The slip gives no new latitude and no new longitude.
      Write the correction the watch can pencil on the chart: two sentences, the chart number, the buoy, and the 300 yard move.
    TEXT

    REST_QUESTION = "That note was too short to pencil on the chart. Write the correction in two sentences. Name chart 18465 and buoy DH and the 300 yard move."

    CLIP = 64
    SHORT_LENGTH = 80

    Result = Struct.new(
      :clipped_content,
      :clipped_thinking,
      :clipped_finish,
      :clipped_max_tokens,
      :clipped_status,
      :asked_again,
      :posted_content,
      :posted_status,
      :posted_finish,
      :roles,
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
      chat.with_max_output_tokens(CLIP)

      clipped = chat.ask(SLIP_QUESTION)
      clipped_text = clipped.content.to_s.strip
      short_note = clipped_text.empty? || clipped.max_tokens? || clipped_text.length < SHORT_LENGTH

      if short_note
        chat.with_max_output_tokens(nil)
        posted = chat.ask(REST_QUESTION)
        asked_again = true
      else
        posted = clipped
        asked_again = false
      end

      Result.new(
        clipped_content: clipped.content,
        clipped_thinking: clipped.thinking&.text,
        clipped_finish: clipped.finish_reason,
        clipped_max_tokens: clipped.max_tokens?,
        clipped_status: clipped.raw.status,
        asked_again: asked_again,
        posted_content: posted.content,
        posted_status: posted.raw.status,
        posted_finish: posted.finish_reason,
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "chart_notice") do
    result = JuanDeFucaChart::ChartNotice.conduct
  end

  puts "clipped finish=#{result.clipped_finish} max_tokens=#{result.clipped_max_tokens} " \
       "status=#{result.clipped_status} chars=#{result.clipped_content.to_s.length} asked_again=#{result.asked_again}"
  puts result.clipped_content.inspect
  puts
  puts "posted finish=#{result.posted_finish} status=#{result.posted_status}"
  puts result.posted_content
end
