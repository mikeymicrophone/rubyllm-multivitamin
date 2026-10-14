# frozen_string_literal: true

# Structured output · 01 · Point Wilson tide heights
#
# Teaches:
# - with_schema takes a Schematist::Schema subclass. RubyLLM 2.1.1 has no
#   RubyLLM::Schema class. RubyLLM::Models::Schema validates the model
#   registry, and it is not the chat DSL.
# - response.content stays the JSON text. response.parsed is the Hash.
# - Parsed keys are strings. A number field comes back as a number.
# - A Schematist title becomes the schema name on the wire.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideHeights
  class PostedTideBoard < Schematist::Schema
    title "posted_tide_board"
    description "Times and heights copied from the Point Wilson tide board"

    string :station, description: "Light station name, copied from the board"
    string :low_clock, description: "Clock time of low water, 24-hour HH:MM"
    number :low_height_ft, description: "Low water in feet above MLLW, as a number"
    string :high_clock, description: "Clock time of high water, 24-hour HH:MM"
    number :high_height_ft, description: "High water in feet above MLLW, as a number"
    string :alden_clears, description: "Clock time Alden clears the kelp ledge"
    string :retort_float, description: "Clock time Retort can use the float"
  end

  class TideHeights
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Fill posted_tide_board from the board in the question.
      Copy clock times and heights exactly. Do not invent a tide.
    TEXT

    BOARD = <<~TEXT.strip
      Point Wilson tide board for Wednesday 14 October 2026.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      Alden clears the kelp ledge at 10:46.
      Retort can use the float at 08:57.
    TEXT

    Result = Struct.new(:content, :parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(PostedTideBoard)

      answer = chat.ask(BOARD)

      Result.new(
        content: answer.content,
        parsed: answer.parsed,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
      )
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
  Multivitamin::Cassettes.play(__dir__, "tide_heights") do
    result = PointWilsonTideHeights::TideHeights.conduct
  end

  puts result.content
  puts JSON.generate(result.parsed)
end
