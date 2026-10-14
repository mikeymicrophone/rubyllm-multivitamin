# frozen_string_literal: true

# Multimodal attachments · 06 · Neah Bay pilot ladder
#
# Teaches:
# - with: takes an array of images in one ask.
# - Each image becomes its own input_image part, in that order.
# - The reply has to use both photographs, not only the first.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayLadderPhotographs
  # The pilot looks at the ladder against the ship, then at the cracked rung.
  class PilotLadder
    SIDE = File.expand_path("ladder-side.png", __dir__)
    RUNG = File.expand_path("rung-seven.png", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the pilot boarding at Neah Bay.
      The first photograph is the ladder against the ship's side.
      The second photograph is the close-up of one rung.
      Answer in one sentence.
      Include the rung count and the number of the cracked rung.
      Do not invent a figure.
    TEXT

    LADDER_QUESTION = "How many rungs are on the ladder, and which rung must the pilot not use?"

    Result = Struct.new(:report, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      report = chat.ask(LADDER_QUESTION, with: [SIDE, RUNG])

      Result.new(
        report: report.content,
        finish: report.finish_reason,
        input_tokens: report.tokens.input,
        cost: report.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "pilot_ladder") do
    result = NeahBayLadderPhotographs::PilotLadder.conduct
  end

  puts result.report
end
