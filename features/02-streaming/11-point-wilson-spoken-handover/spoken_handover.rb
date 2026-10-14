# frozen_string_literal: true

# Streaming · 11 · Point Wilson spoken handover
#
# Teaches:
# - Two streamed asks share one chat.
# - The second request carries the first answer in input.
#   gpt-4.1-mini does not send reasoning_details.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonSpokenHandover
  # The outgoing watch at Point Wilson speaks the night boards, then answers
  # the relief's question about the lens cabinet. Both answers are streamed.
  class SpokenHandover
    INSTRUCTIONS = <<~TEXT.strip
      You are the outgoing tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Brief the overnight relief in short sentences.
      Use only the boards in this chat.
      Name the low water time 07:05 and whether the horn is running.
      Do not invent a tide height.
    TEXT

    BOARDS_QUESTION = <<~TEXT.strip
      Overnight handover at Point Wilson, Wednesday night 14 October 2026.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Tide board: low water 07:05, 1.1 ft above MLLW.
      Foghorn card: visibility is 1 mile, so the horn is running. Blast 3 seconds, silent 27 seconds.
      Lens cabinet: closed. The lamp is burning. Do not open the cabinet on this watch.
      Speak the brief. When is low water, and is the horn running?
    TEXT

    CABINET_QUESTION = "The relief asks whether to open the lens cabinet at low water. Answer from both boards."

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
      cabinet = chat.ask(CABINET_QUESTION) { |chunk| keep(cabinet_pieces, chunk) }

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

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "spoken_handover") do
    result = PointWilsonSpokenHandover::SpokenHandover.conduct
  end

  puts result.brief
  puts
  puts result.cabinet
end
