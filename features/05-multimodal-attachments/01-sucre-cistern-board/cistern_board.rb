# frozen_string_literal: true

# Multimodal attachments · 01 · Sucre cistern board
#
# Teaches:
# - ask takes a local image path with with:.
# - RubyLLM sends that file as an image part. The caller does not set a MIME type.
# - The reply is still a RubyLLM::Message, with tokens and a finish reason.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SucreCisternBoardPhoto
  # The Quispe courtyard reads the chalked cistern board from a photograph,
  # not from a typed copy of the heights.
  class CisternBoard
    PHOTO = File.expand_path("cistern-board.png", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the household clerk in a Sucre courtyard.
      Answer in one sentence from the photograph only.
      Include the posted height time, the posted height, and the clock time when Rosa may pump the patio.
      Do not invent a figure.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      The photograph is the cistern board posted in the Quispe courtyard for Wednesday 14 October 2026.
      When is the posted height, what is that height, and when may Rosa pump the patio?
    TEXT

    Result = Struct.new(:brief, :roles, :finish, :input_tokens, :output_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      brief = chat.ask(BOARD_QUESTION, with: PHOTO)

      Result.new(
        brief: brief.content,
        roles: chat.messages.map(&:role),
        finish: brief.finish_reason,
        input_tokens: brief.tokens.input,
        output_tokens: brief.tokens.output,
        cost: brief.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "cistern_board") do
    result = SucreCisternBoardPhoto::CisternBoard.conduct
  end

  puts result.brief
end
