# frozen_string_literal: true

# Agents · 13 · Admiralty Inlet watch capstone
#
# Teaches:
# - One agent can declare model, instructions, tools, and schema together.
# - The first ask reads the posted board through the tool and fills the schema.
# - A second ask keeps that board and answers the lens question.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletWatchCapstone
  class PostedTideBoard < RubyLLM::Tool
    description "Reads the tide board posted at Point Wilson for the Admiralty Inlet watch"

    def self.tool_name
      "posted_tide_board"
    end

    BOARD = <<~TEXT.strip
      Point Wilson tide board for Wednesday 15 October 2026.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      Alden clears the kelp ledge at 10:46.
      Retort can use the float at 08:57.
      The Fresnel lens crew is in the cabinet until 09:30.
    TEXT

    def execute
      BOARD
    end
  end

  class WatchDesk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools PostedTideBoard
    tool_options choice: PostedTideBoard
    temperature 0.2

    instructions <<~TEXT.strip
      You are the watch clerk for Admiralty Inlet at Point Wilson Light Station.
      Call posted_tide_board once on the first question.
      Fill the watch card from that board.
      Name Alden, Retort, 10:46, and 08:57.
      Do not invent a tide height.
    TEXT

    schema do
      string :station, description: "Light station name"
      string :alden_clears, description: "Clock time Alden clears the kelp ledge"
      string :retort_float, description: "Clock time Retort can use the float"
      string :lens_until, description: "Clock time the lens cabinet must stay shut"
    end
  end

  class WatchCard
    BOARD_QUESTION = <<~TEXT.strip
      Overnight watch handover, Admiralty Inlet, Wednesday 15 October 2026.
      Fill the watch card from the posted Point Wilson board.
    TEXT

    LENS_QUESTION = "The lens cabinet stays open until 09:30. Should the watch hail the lens crew before Alden sails at 10:46?"

    Result = Struct.new(
      :parsed,
      :follow_up,
      :roles,
      :tool_content,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      agent = open_agent
      opening = agent.ask(BOARD_QUESTION)
      agent.with_schema(nil)
      follow_up = agent.ask(LENS_QUESTION)
      tool_message = agent.messages.find { |message| message.role == :tool }

      Result.new(
        parsed: opening.parsed,
        follow_up: follow_up.content,
        roles: agent.messages.map(&:role),
        tool_content: tool_message&.content,
        input_tokens: follow_up.tokens.input,
        cost: follow_up.cost.total
      )
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = WatchDesk.new(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(agent, provider: :openai)
      agent
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
  Multivitamin::Cassettes.play(__dir__, "watch_capstone") do
    result = AdmiraltyInletWatchCapstone::WatchCard.conduct
  end

  puts JSON.generate(result.parsed)
  puts
  puts result.follow_up
end
