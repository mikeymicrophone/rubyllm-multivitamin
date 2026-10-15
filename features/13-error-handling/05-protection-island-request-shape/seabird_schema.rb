# frozen_string_literal: true

# Error handling · 05 · Protection Island request shape
#
# Teaches:
# - A strict schema that leaves a property out of required is HTTP 400
#   and BadRequestError.
# - request_shape names roles and sizes. It does not hold the colony
#   counts.
# - request_shape.to_h has the same keys every time.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ProtectionIslandRequestShape
  # The refuge clerk on Protection Island posts a rhinoceros-auklet count
  # through a broken schema. OpenAI refuses the format. The desk logs the
  # shape, not the burrow numbers.
  class SeabirdSchema
    BROKEN = {
      name: "SeabirdCount",
      strict: true,
      schema: {
        type: "object",
        properties: {
          colony: { type: "string", description: "Island or bluff the count names" },
          burrows: { type: "integer", description: "Occupied auklet burrows" },
          fledglings: { type: "integer", description: "Fledgling count, only when the card has one" }
        },
        required: %w[colony burrows],
        additionalProperties: false
      }
    }.freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the refuge clerk on Protection Island.
      Fill SeabirdCount from the card. Copy the colony and the burrow count.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Rhinoceros auklet card, Protection Island, Thursday 15 October 2026.
      Refuge notes: https://www.fws.gov/refuge/protection-island.
      Colony: Violet Point.
      Occupied burrows: 412.
      The card has no fledgling count.
    TEXT

    Result = Struct.new(
      :error,
      :status,
      :message,
      :shape,
      :shape_hash,
      :shape_text,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(BROKEN)

      error = nil
      begin
        chat.ask(CARD_QUESTION)
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(
        error: error,
        status: error&.response&.status,
        message: error&.message,
        shape: error&.request_shape,
        shape_hash: error&.request_shape&.to_h,
        shape_text: error&.request_shape&.to_s
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "seabird_schema") do
    result = ProtectionIslandRequestShape::SeabirdSchema.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.message
  puts result.shape_text
end
