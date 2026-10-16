# frozen_string_literal: true

# Structured output · 05 · Stone Town spice stall
#
# Teaches:
# - with_schema accepts a raw JSON Schema hash. Schematist is optional.
# - A hash with no name and no title is sent as name "response".
# - additionalProperties: false has to be written on a manual schema.
#   Schematist sets it for you.

require "json"
require_relative "../../../support/runtime"

module StoneTownSpiceStall
  STALL_SCHEMA = {
    type: "object",
    properties: {
      stall: { type: "string", description: "Stall number on the Darajani spice lane" },
      seller: { type: "string", description: "Seller at the stall, as written" },
      frontage_m: { type: "number", description: "Frontage of the stall in metres" },
      aisle: {
        type: "string",
        enum: ["left", "right"],
        description: "Which side of the lane the stall faces"
      }
    },
    required: %w[stall seller frontage_m aisle],
    additionalProperties: false
  }.freeze

  class StallAssignment
    INSTRUCTIONS = <<~TEXT.strip
      You are the market clerk at Darajani in Stone Town, Zanzibar.
      Fill the schema from the assignment. Copy the stall, the seller, the
      frontage, and the side. Do not add fields.
    TEXT

    ASSIGNMENT = <<~TEXT.strip
      Darajani spice lane, Stone Town, Wednesday 14 October 2026.
      Market office: https://whc.unesco.org/en/list/173
      Stall 7, Amina Clove, left side of the lane.
      Frontage 11.2 m.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(STALL_SCHEMA)
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

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "spice_stall") do
    StoneTownSpiceStall::StallAssignment.conduct
  end

  puts JSON.generate(result.parsed)
end
