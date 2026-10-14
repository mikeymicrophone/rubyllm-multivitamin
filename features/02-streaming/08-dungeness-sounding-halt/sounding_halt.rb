# frozen_string_literal: true

# Streaming · 08 · Dungeness sounding halt
#
# Teaches:
# - chat.cancel marks the stream, and the next chunk checkpoint raises
#   RubyLLM::CancelledError.
# - CancelledError inherits StandardError, not RubyLLM::Error.
# - The partial call stays with the mate. The assistant turn is not appended.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DungenessSoundingHalt
  # The leadsman calls soundings off Dungeness Spit. The mate stops the
  # call after two spoken pieces, before the rest of the cast is logged.
  class SoundingHalt
    INSTRUCTIONS = <<~TEXT.strip
      You are the leadsman on a ship off Dungeness Spit in the Strait of Juan de Fuca.
      Call the four soundings in order, one short sentence each.
      Use only the cast on the card.
    TEXT

    CAST_QUESTION = <<~TEXT.strip
      Sounding cast Wednesday 14 October 2026, north of Dungeness Spit.
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      First call: six fathoms.
      Second call: five fathoms.
      Third call: by the mark, five.
      Fourth call: four fathoms, and the mate holds her.
      Call the four soundings.
    TEXT

    Result = Struct.new(:spoken, :error, :roles, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

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
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
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
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "sounding_halt") do
    result = DungenessSoundingHalt::SoundingHalt.conduct
  end

  puts result.spoken.join
  puts
  puts result.error.class
end
