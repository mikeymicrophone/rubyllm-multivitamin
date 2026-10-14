# frozen_string_literal: true

# Structured output · 05 · Friday Harbor berth slip
#
# Teaches:
# - with_schema accepts a raw JSON Schema hash. Schematist is optional.
# - A hash with no name and no title is sent as name "response".
# - additionalProperties: false has to be written on a manual schema.
#   Schematist sets it for you.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborBerthSlip
  SLIP_SCHEMA = {
    type: "object",
    properties: {
      slip: { type: "string", description: "Slip number on the Friday Harbor float" },
      boat: { type: "string", description: "Boat alongside, as written" },
      depth_ft: { type: "number", description: "Water under the slip in feet" },
      alongside: {
        type: "string",
        enum: ["port", "starboard"],
        description: "Which side is to the float"
      }
    },
    required: %w[slip boat depth_ft alongside],
    additionalProperties: false
  }.freeze

  class SlipAssignment
    INSTRUCTIONS = <<~TEXT.strip
      You are the berth clerk at Friday Harbor.
      Fill the schema from the assignment. Copy the slip, the boat, the
      depth, and the side. Do not add fields.
    TEXT

    ASSIGNMENT = <<~TEXT.strip
      Friday Harbor float, Wednesday 14 October 2026.
      Marina office: https://www.portfridayharbor.org/
      Slip 7, F/V Kulshan, port side to.
      Water under the slip 11.2 ft.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(SLIP_SCHEMA)
      answer = chat.ask(ASSIGNMENT)

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
  Multivitamin::Cassettes.play(__dir__, "berth_slip") do
    result = FridayHarborBerthSlip::SlipAssignment.conduct
  end

  puts JSON.generate(result.parsed)
end
