# frozen_string_literal: true

# Error handling · 13 · Restoration Point error desk
#
# Teaches:
# - The desk rescues BadRequestError, logs request_shape.to_h, and asks
#   again without the broken schema.
# - The logged hash has no berth text.
# - A second chat on gpt-4.1-mini still briefs the slip.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RestorationPointErrorDesk
  # The ferry-slip desk at Restoration Point, on the south end of
  # Bainbridge Island, first posts a broken berth schema. The 400 is
  # logged as a shape. The clerk then asks for a prose brief on the
  # same model without the schema.
  class ErrorDesk
    BROKEN = {
      name: "SlipBerth",
      strict: true,
      schema: {
        type: "object",
        properties: {
          slip: { type: "string", description: "Slip letter and number" },
          boat: { type: "string", description: "Boat assigned" },
          power: { type: "string", description: "Shore power, only when posted" }
        },
        required: %w[slip boat],
        additionalProperties: false
      }
    }.freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the ferry-slip clerk at Restoration Point, Bainbridge Island.
      Fill SlipBerth from the board. Copy the slip and the boat.
    TEXT

    PROSE_INSTRUCTIONS = <<~TEXT.strip
      You are the ferry-slip clerk at Restoration Point, Bainbridge Island.
      Answer in two short sentences.
      Use only the board in the question.
      Name G-4 and Alden.
      Do not invent a berth.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Berth board posted at Restoration Point, Thursday 15 October 2026.
      Ferry notes: https://wsdot.wa.gov/travel/washington-state-ferries.
      G-4 is open and is where Alden should tie, 38 feet, no shore-power note.
      H-1: the watch boat Kelp, staying.
      Where do you put Alden?
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
  Multivitamin::Cassettes.play(__dir__, "error_desk") do
    result = RestorationPointErrorDesk::ErrorDesk.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.shape_text
  puts
  puts result.brief
end
