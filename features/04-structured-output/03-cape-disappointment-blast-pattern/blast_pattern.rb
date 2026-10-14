# frozen_string_literal: true

# Structured output · 03 · Cape Disappointment blast pattern
#
# Teaches:
# - A string enum constrains the pattern with_schema will accept.
# - RubyLLM::Judge is a different call. It posts to OpenAI Decisions
#   (POST /v1/decisions) on gpt-6-luna, and a choice question returns one
#   of the declared options plus a probability for each.
# - The schema structures a card. The judgment decides from the same card
#   without a JSON schema.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentBlastPattern
  class HornCard < Schematist::Schema
    title "horn_card"
    description "The blast pattern posted at Cape Disappointment"

    string :pattern,
           enum: ["three-second blast", "two-blast group", "silent"],
           description: "The pattern named on the card"
    integer :compressor_psi, description: "Compressor pressure in psi, as an integer"
  end

  # Decisions choice. The descriptions are the instructions; the method
  # name is only how Ruby reads the answer back.
  class PatternCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    choice :pattern, "Which blast pattern does the card post?" do
      three_second_blast "One blast of about three seconds, then a long silence"
      two_blast_group "Two short blasts grouped together"
      silent "The horn is secured and not sounding"
    end
  end

  class BlastPattern
    INSTRUCTIONS = <<~TEXT.strip
      You are the foghorn tender at Cape Disappointment.
      Fill horn_card from the card. Use the enum value that matches the card.
      Copy the compressor pressure as an integer.
    TEXT

    CARD = <<~TEXT.strip
      Cape Disappointment foghorn card for Wednesday 14 October 2026.
      Headland: https://parks.wa.gov/find-parks/state-parks/cape-disappointment-state-park
      Pattern posted: one blast of three seconds, then silent 27 seconds.
      Do not use the two-blast group. The horn is not silent.
      Compressor holding 92 psi.
    TEXT

    Result = Struct.new(
      :parsed, :choice, :probabilities, :confidence, :roles, :finish, :input_tokens, :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(HornCard)
      answer = chat.ask(CARD)

      judgment = PatternCall.judge(CARD)
      pattern = judgment.pattern

      Result.new(
        parsed: answer.parsed,
        choice: pattern.choice,
        probabilities: pattern.probabilities,
        confidence: pattern.confidence,
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
  Multivitamin::Cassettes.play(__dir__, "blast_pattern") do
    result = CapeDisappointmentBlastPattern::BlastPattern.conduct
  end

  puts JSON.generate(result.parsed)
  puts({ choice: result.choice, probabilities: result.probabilities, confidence: result.confidence }.inspect)
end
