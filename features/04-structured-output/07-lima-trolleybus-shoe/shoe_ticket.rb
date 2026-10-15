# frozen_string_literal: true

# Structured output · 07 · Lima trolleybus shoe ticket
#
# Teaches:
# - required: false leaves a field out of the schema's required list.
# - OpenAI strict mode is off when any property is optional. The request
#   sends strict false.
# - The parsed Hash shows which optional keys came back.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LimaTrolleybusShoe
  class ShoeTicket < Schematist::Schema
    title "shoe_ticket"
    description "Carbon-shoe service for one Lima trolleybus"

    string :car, description: "Car number from the depot board"
    number :volts, description: "Line voltage as a number"
    string :replaced_on,
           required: false,
           description: "ISO date the shoe was replaced. Omit this field when the ticket gives no date."
    string :pencil_note,
           required: false,
           description: "The pencil note, when the ticket has one. Omit this field when the ticket has no note."
  end

  class ServiceTicket
    INSTRUCTIONS = <<~TEXT.strip
      You are the shoe fitter at the Avenida Arequipa depot in Lima.
      Fill shoe_ticket from the ticket.
      Omit replaced_on. The ticket has no date.
      Include pencil_note, because the ticket has a note.
    TEXT

    TICKET = <<~TEXT.strip
      Lima trolleybus shoe service, Wednesday 14 October 2026.
      Depot board: https://www.protransporte.gob.pe/
      Car: Trolebús 12.
      Line reading 12.4 volts.
      No replacement date on this ticket.
      Pencil note: shoe glazed.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(ShoeTicket)
      answer = chat.ask(TICKET)

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
  Multivitamin::Cassettes.play(__dir__, "shoe_ticket") do
    result = LimaTrolleybusShoe::ServiceTicket.conduct
  end

  puts JSON.generate(result.parsed)
  puts result.parsed.keys.inspect
end
