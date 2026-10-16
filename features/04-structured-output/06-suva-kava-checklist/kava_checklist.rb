# frozen_string_literal: true

# Structured output · 06 · Suva kava checklist
#
# Teaches:
# - A manual schema can set name:. That name is what the request sends.
#   The default, when name and title are both absent, is "response".
# - Boolean fields stay booleans.
# - A module_function entry point uses a fluent chat and a plain schema hash.

require "json"
require_relative "../../../support/runtime"

module SuvaKavaChecklist
  CHECKLIST_SCHEMA = {
    name: "KavaServingChecklist",
    schema: {
      type: "object",
      properties: {
        circle: { type: "string", description: "Circle named on the serving order" },
        vale: { type: "string", description: "House where the tanoa is set" },
        tanoa_ready: { type: "boolean", description: "True when the tanoa is filled and ready" },
        herald_side: {
          type: "string",
          enum: ["east", "west"],
          description: "Side the herald sits on"
        },
        steps: {
          type: "array",
          description: "The checks the mata ni vanua initialed",
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
      required: %w[circle vale tanoa_ready herald_side steps],
      additionalProperties: false
    }
  }.freeze

  module ServingChecklist
    module_function

    INSTRUCTIONS = <<~TEXT.strip
      You are the mata ni vanua at a kava circle in Suva.
      Fill KavaServingChecklist from the order.
      tanoa_ready and each ready flag are booleans, not the words yes or no.
      Include both steps from the order.
    TEXT

    ORDER = <<~TEXT.strip
      Kava order, Wednesday 14 October 2026, Suva.
      Serving house: https://www.fiji.travel/
      Circle: Vunisa circle.
      Vale: Suva.
      Tanoa filled on the east side and ready.
      Step: water drawn, ready.
      Step: strainer set, ready.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def conduct
      configure

      chat = open_chat.with_instructions(INSTRUCTIONS).with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      answer = chat.with_schema(CHECKLIST_SCHEMA).ask(ORDER)

      Result.new(
        parsed: answer.parsed,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
      )
    end

    def open_chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))

    def configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "kava_checklist") do
    SuvaKavaChecklist::ServingChecklist.conduct
  end

  puts JSON.generate(result.parsed)
end
