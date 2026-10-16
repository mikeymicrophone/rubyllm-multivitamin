# frozen_string_literal: true

# Error handling · 05 · Hue imperial lantern
#
# Teaches:
# - A strict schema that leaves a property out of required is HTTP 400
#   and BadRequestError.
# - request_shape names roles and sizes. It does not hold the ward
#   counts.
# - request_shape.to_h has the same keys every time.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HueImperialLantern
  # The festival clerk in Hue posts a silk-frame lantern count through a
  # broken schema. OpenAI refuses the format. The desk logs the shape,
  # not the hung numbers.
  class LanternSchema
    BROKEN = {
      name: "LanternCount",
      strict: true,
      schema: {
        type: "object",
        properties: {
          ward: { type: "string", description: "Ward or street the count names" },
          hung: { type: "integer", description: "Silk-frame lanterns already hung" },
          spare_wicks: { type: "integer", description: "Spare wicks, only when the card has one" }
        },
        required: %w[ward hung],
        additionalProperties: false
      }
    }.freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the festival clerk in Hue.
      Fill LanternCount from the card. Copy the ward and the hung count.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Silk-frame lantern card, Hue, Friday 16 October 2026.
      Festival notes: https://vietnam.travel/.
      Ward: Gia Hoi.
      Hung: 186.
      The card has no spare-wick count.
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
  Multivitamin::Cassettes.play(__dir__, "lantern_schema") do
    result = HueImperialLantern::LanternSchema.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.message
  puts result.shape_text
end
