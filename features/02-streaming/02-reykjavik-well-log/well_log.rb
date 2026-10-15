# frozen_string_literal: true

# Streaming · 02 · Reykjavík geothermal well log
#
# Teaches:
# - Write each spoken chunk to a terminal as it arrives.
# - with_thinking(false) keeps the log to the spoken card.
# - The cassette stores the SSE body, and a replay yields the same pieces.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ReykjavikWellLog
  # The well tender at Hellisheiði calls the posted pulse card into the
  # log as the chunks arrive. A replay of the cassette calls the same pieces.
  class WellLog
    INSTRUCTIONS = <<~TEXT.strip
      You are the well tender at Hellisheiði Power Plant outside Reykjavík.
      Call the posted card in two short sentences.
      Use only the card in the question.
      Name the pulse of 2 minutes and the quiet of 18 minutes.
      Do not invent a wellhead pressure.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Geothermal pulse card posted Wednesday 14 October 2026 at Hellisheiði, Reykjavík.
      Plant notes: https://www.or.is/en/projects/hellisheidi-geothermal-power-plant
      Well HE-39 is on bleed. Visibility in the steam plume is under 1 kilometre, so the pulse is running.
      Pulse 2 minutes. Quiet 18 minutes.
      Call the card into the log.
    TEXT

    Result = Struct.new(:speech, :pieces, :thinking_chunks, keyword_init: true)

    def self.conduct(well_log)
      configure
      call_card(well_log)
    end

    def self.call_card(well_log)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      # This model streams reasoning before the words unless thinking is off.
      # The log is the spoken card, so the reasoning chunks stay off the well.
      Multivitamin::Models.quiet_thinking(chat, provider: :openrouter)

      pieces = []
      thinking_chunks = 0
      message = chat.ask(CARD_QUESTION) do |chunk|
        thinking_chunks += 1 if chunk.thinking&.text
        piece = chunk.content.to_s
        next if piece.empty?

        pieces << piece
        well_log.write(piece)
        well_log.flush if well_log.respond_to?(:flush)
      end

      Result.new(speech: message.content, pieces: pieces, thinking_chunks: thinking_chunks)
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "well_log") do
    result = ReykjavikWellLog::WellLog.conduct($stdout)
  end

  puts
end
