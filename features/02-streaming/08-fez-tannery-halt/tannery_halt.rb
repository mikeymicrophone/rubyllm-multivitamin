# frozen_string_literal: true

# Streaming · 08 · Fez tannery pit halt
#
# Teaches:
# - chat.cancel marks the stream, and the next chunk checkpoint raises
#   RubyLLM::CancelledError.
# - CancelledError inherits StandardError, not RubyLLM::Error.
# - The partial call stays with the master. The assistant turn is not appended.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FezTanneryHalt
  # The pit caller at Chouara reads four lime-pit strengths. The master
  # stops the call after two spoken pieces, before the rest of the round
  # is logged.
  class TanneryHalt
    INSTRUCTIONS = <<~TEXT.strip
      You are the pit caller at Chouara Tannery in Fez.
      Call the four pit readings in order, one short sentence each.
      Use only the round on the card.
    TEXT

    CAST_QUESTION = <<~TEXT.strip
      Lime-pit round Wednesday 14 October 2026, Chouara Tannery, Fez.
      Medina notes: https://whc.unesco.org/en/list/170/
      First call: six Baumé.
      Second call: five Baumé.
      Third call: by the mark, five.
      Fourth call: four Baumé, and the master holds the hides.
      Call the four readings.
    TEXT

    Result = Struct.new(:spoken, :error, :roles, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openrouter)

      spoken = []
      error = nil
      begin
        chat.ask(CAST_QUESTION) do |chunk|
          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          chat.cancel if spoken.size == 2
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      Result.new(spoken: spoken, error: error, roles: chat.messages.map(&:role))
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
  Multivitamin::Cassettes.play(__dir__, "tannery_halt") do
    result = FezTanneryHalt::TanneryHalt.conduct
  end

  puts result.spoken.join
  puts
  puts result.error.class
end
