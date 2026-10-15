# frozen_string_literal: true

# Tokens and cost · 12 · Turn Point current-halt cancelled usage
#
# Teaches:
# - chat.cancel raises CancelledError after the block. The assistant
#   turn is not appended.
# - The cancelled attempt still sits on chat.usage_entries.
# - If the stream stopped before a usage chunk, chat.cost.total is nil
#   rather than a fake zero.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TurnPointCurrentHalt
  # The current clerk at Turn Point, Stuart Island, starts calling the
  # Boundary Pass race and is stopped after two spoken pieces. The desk
  # still has to file whatever usage that attempt produced.
  class CurrentHalt
    INSTRUCTIONS = <<~TEXT.strip
      You are the current clerk at Turn Point Light, Stuart Island, looking into Boundary Pass.
      Call the four race figures in order, one short sentence each.
      Use only the race card.
    TEXT

    RACE_QUESTION = <<~TEXT.strip
      Turn Point race card, Wednesday 14 October 2026, flood in Boundary Pass.
      Light list: https://www.navcen.uscg.gov/
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      First call: flood 3.4 knots at the Turn Point light.
      Second call: 4.1 knots in mid-channel toward East Point.
      Third call: 2.6 knots off Skipjack Island.
      Fourth call: slack filling, and the tanker Polar Adventure holds south of the light.
      Call the four figures.
    TEXT

    Result = Struct.new(
      :spoken,
      :error,
      :roles,
      :chat_input,
      :chat_output,
      :chat_cost,
      :attempt_status,
      :attempt_count,
      :message_token_sum,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

      spoken = []
      error = nil
      begin
        chat.ask(RACE_QUESTION) do |chunk|
          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          chat.cancel if spoken.size == 2
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      message_token_sum = chat.messages.sum { |message| message.tokens.input.to_i }

      Result.new(
        spoken: spoken,
        error: error,
        roles: chat.messages.map(&:role),
        chat_input: chat.tokens.input,
        chat_output: chat.tokens.output,
        chat_cost: chat.cost.total,
        attempt_status: chat.usage_entries.last&.status,
        attempt_count: chat.usage_entries.size,
        message_token_sum: message_token_sum
      )
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
  Multivitamin::Cassettes.play(__dir__, "current_halt") do
    result = TurnPointCurrentHalt::CurrentHalt.conduct
  end

  puts result.spoken.join
  puts
  puts "#{result.error.class} status=#{result.attempt_status} chat_cost=#{result.chat_cost.inspect} " \
       "chat_in=#{result.chat_input.inspect}"
end
