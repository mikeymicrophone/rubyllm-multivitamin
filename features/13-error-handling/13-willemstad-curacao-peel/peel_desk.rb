# frozen_string_literal: true

# Error handling · 13 · Willemstad curaçao peel
#
# Teaches:
# - The desk rescues BadRequestError, logs request_shape.to_h, and asks
#   again without the broken schema.
# - The logged hash has no vat text.
# - A second chat on gpt-4.1-mini still briefs the lot.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module WillemstadCuracaoPeel
  # The steeping desk at Landhuis Chobolobo, Willemstad, first posts a
  # broken peel schema. The 400 is logged as a shape. The clerk then asks
  # for a prose brief on the same model without the schema.
  class PeelDesk
    BROKEN = {
      name: "PeelLot",
      strict: true,
      schema: {
        type: "object",
        properties: {
          vat: { type: "string", description: "Vat letter and number" },
          lot: { type: "string", description: "Lot assigned" },
          pith: { type: "string", description: "Pith note, only when posted" }
        },
        required: %w[vat lot],
        additionalProperties: false
      }
    }.freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the steeping clerk at Landhuis Chobolobo, Willemstad.
      Fill PeelLot from the board. Copy the vat and the lot.
    TEXT

    PROSE_INSTRUCTIONS = <<~TEXT.strip
      You are the steeping clerk at Landhuis Chobolobo, Willemstad.
      Answer in two short sentences.
      Use only the board in the question.
      Name C-4 and Marisol.
      Do not invent a vat.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Peel board posted at Landhuis Chobolobo, Willemstad, Friday 16 October 2026.
      Distillery notes: https://www.curacaoliqueur.com/.
      C-4 is open and is where Marisol's bitter-orange lot should steep, 38 kilos, no pith note.
      D-1: last week's laraha peel, staying.
      Where do you put Marisol?
    TEXT

    Result = Struct.new(
      :error,
      :status,
      :shape_hash,
      :shape_text,
      :brief,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      error = nil
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(BROKEN)
      begin
        chat.ask(BOARD_QUESTION)
      rescue RubyLLM::Error => raised
        error = raised
      end

      spare = open_chat
      spare.with_instructions(PROSE_INSTRUCTIONS)
      spare.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(spare, provider: :openai)
      brief = spare.ask(BOARD_QUESTION)

      Result.new(
        error: error,
        status: error&.response&.status,
        shape_hash: error&.request_shape&.to_h,
        shape_text: error&.request_shape&.to_s,
        brief: brief.content,
        roles: spare.messages.map(&:role)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "peel_desk") do
    result = WillemstadCuracaoPeel::PeelDesk.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.shape_text
  puts
  puts result.brief
end
