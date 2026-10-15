# frozen_string_literal: true

# Error handling · 10 · Browns Point cancelled brief
#
# Teaches:
# - chat.cancel marks the stream. The next chunk checkpoint raises
#   CancelledError.
# - CancelledError inherits StandardError, not RubyLLM::Error.
# - The assistant turn is not appended.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BrownsPointCancelledBrief
  # The fog clerk at Browns Point, on Commencement Bay, starts a spoken
  # visibility brief and stops it after two spoken pieces. The rest of
  # the card stays on the tape. The desk never posts a half brief.
  class CancelledBrief
    INSTRUCTIONS = <<~TEXT.strip
      You are the fog clerk at Browns Point Light on Commencement Bay.
      Read the visibility card in four short sentences, one fact each.
      Use only the card.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Visibility card posted at Browns Point, Thursday 15 October 2026.
      Park page: https://www.metroparkstacoma.org/place/browns-point-lighthouse-park/.
      First fact: visibility 0.6 mile in coal smoke from the tideflats.
      Second fact: horn running, blast 3 seconds.
      Third fact: the seiner Cape Flattery is holding off the sandspit.
      Fourth fact: the Browns Point float is closed to the watch boat.
      Read the four facts.
    TEXT

    Result = Struct.new(:spoken, :error, :roles, :is_llm_error, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      spoken = []
      error = nil
      begin
        chat.ask(CARD_QUESTION) do |chunk|
          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          chat.cancel if spoken.size == 2
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      Result.new(
        spoken: spoken,
        error: error,
        roles: chat.messages.map(&:role),
        is_llm_error: error.is_a?(RubyLLM::Error)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "cancelled_brief") do
    result = BrownsPointCancelledBrief::CancelledBrief.conduct
  end

  puts result.spoken.join
  puts result.error.class
end
