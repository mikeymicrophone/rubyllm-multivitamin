# frozen_string_literal: true

# Multimodal attachments · 01 · Point Wilson tide board
#
# Teaches:
# - ask takes a local image path with with:.
# - RubyLLM sends that file as an image part. The caller does not set a MIME type.
# - The reply is still a RubyLLM::Message, with tokens and a finish reason.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideBoardPhoto
  # The incoming watch reads the chalked board from a photograph, not from
  # a typed copy of the heights.
  class TideBoard
    PHOTO = File.expand_path("tide-board.png", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Answer in one sentence from the photograph only.
      Include the low water time, the low water height, and the clock time when Alden clears the kelp ledge.
      Do not invent a figure.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      The photograph is the tide board posted at Point Wilson for Wednesday 14 October 2026.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      When is low water, what is that height, and when does Alden clear the kelp ledge?
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
  Multivitamin::Cassettes.play(__dir__, "tide_board") do
    result = PointWilsonTideBoardPhoto::TideBoard.conduct
  end

  puts result.brief
end
