# frozen_string_literal: true

# Structured output · 06 · Neah Bay pilot checklist
#
# Teaches:
# - A manual schema can set name:. That name is what the request sends.
#   The default, when name and title are both absent, is "response".
# - Boolean fields stay booleans.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayPilotChecklist
  CHECKLIST_SCHEMA = {
    name: "PilotBoardingChecklist",
    schema: {
      type: "object",
      properties: {
        ship: { type: "string", description: "Ship named on the pilot order" },
        boarding_station: { type: "string", description: "Where the pilot boards" },
        ladder_ready: { type: "boolean", description: "True when the ladder is rigged and ready" },
        lee_side: {
          type: "string",
          enum: ["port", "starboard"],
          description: "Side the pilot ladder is on"
        },
        steps: {
          type: "array",
          description: "The checks the mate initialed",
          items: {
            type: "object",
            properties: {
              item: { type: "string" },
              ready: { type: "boolean" }
            },
            required: %w[item ready],
            additionalProperties: false
          }
        }
      },
      required: %w[ship boarding_station ladder_ready lee_side steps],
      additionalProperties: false
    }
  }.freeze

  class BoardingChecklist
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate at the Neah Bay pilot station.
      Fill PilotBoardingChecklist from the order.
      ladder_ready and each ready flag are booleans, not the words yes or no.
      Include both steps from the order.
    TEXT

    ORDER = <<~TEXT.strip
      Pilot order, Wednesday 14 October 2026, Neah Bay.
      Tide station: https://tidesandcurrents.noaa.gov/stationhome.html?id=9443090
      Pilots: https://www.pspilots.org/
      Ship: bulker Nordic Tidemoor.
      Boarding station: Neah Bay.
      Pilot ladder rigged on the port side and ready.
      Step: manropes rove, ready.
      Step: deck lights on, ready.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(CHECKLIST_SCHEMA)
      answer = chat.ask(ORDER)

      Result.new(
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
  Multivitamin::Cassettes.play(__dir__, "pilot_checklist") do
    result = NeahBayPilotChecklist::BoardingChecklist.conduct
  end

  puts JSON.generate(result.parsed)
end
