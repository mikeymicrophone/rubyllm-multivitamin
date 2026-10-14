# frozen_string_literal: true

# Multimodal attachments · 08 · Smith Island barometer round
#
# Teaches:
# - One ask can mix an image and a text file.
# - A text file is a text part wrapped as a file element, not an image.
# - The reply has to use the photograph and the written round.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SmithIslandBarometerRound
  # The glass in the photograph is 06:00. The written round still has 04:00.
  class BarometerRound
    GLASS = File.expand_path("barometer-glass.png", __dir__)
    ROUND = File.expand_path("weather-round.txt", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the weather watch at Smith Island.
      Use both attachments.
      The photograph is the glass at 06:00. The text file is the written round.
      Answer in one sentence.
      Include the 06:00 reading, the 04:00 reading, and the wind.
      Do not invent a figure.
    TEXT

    ROUND_QUESTION = "What does the glass read now, what did it read at 04:00, and what is the wind?"

    Result = Struct.new(:round, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      round = chat.ask(ROUND_QUESTION, with: [GLASS, ROUND])

      Result.new(
        round: round.content,
        finish: round.finish_reason,
        input_tokens: round.tokens.input,
        cost: round.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      chat.with_temperature(0)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "barometer_round") do
    result = SmithIslandBarometerRound::BarometerRound.conduct
  end

  puts result.round
end
