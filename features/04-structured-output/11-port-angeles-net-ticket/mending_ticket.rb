# frozen_string_literal: true

# Structured output · 11 · Port Angeles net ticket
#
# Teaches:
# - Field descriptions steer the model when the ticket is messy: which
#   boat, which fiber, which fathom count, and who the mending is for.
# - A Judge probability is the Decisions form of a yes/no. RubyLLM sends
#   it as a predicate question and reads probability between 0 and 1.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortAngelesNetTicket
  class MendingTicket < Schematist::Schema
    title "mending_ticket"
    description "A handwritten mending ticket from the Port Angeles net loft"

    string :boat, description: "The fishing vessel named on the ticket. Not the loft, and not a boat that was crossed out."
    string :twine, description: "The twine that is still wanted. Ignore a fiber marked not or crossed out."
    number :fathoms, description: "Length in fathoms as a number"
    string :due_for, description: "Who the mending is for. Ignore a name that was crossed out."
  end

  class FridayCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    probability :loft_before_friday,
                "Does this mending have to be in the loft before Friday? Yes when the ticket is due Friday or sooner."
  end

  class HandwrittenTicket
    INSTRUCTIONS = <<~TEXT.strip
      You are the net loft clerk at Port Angeles.
      Fill mending_ticket from the handwritten ticket.
      Trust the field descriptions when the handwriting contradicts itself.
    TEXT

    TICKET = <<~TEXT.strip
      Handwritten, Port Angeles net loft, Wednesday 14 October 2026.
      Marina: https://www.portofpa.com/
      Boat: F/V Kulshan. (the seiner. not the loft. Retort was written then crossed out.)
      Twine no. 18 tarred nylon — NOT the cotton, cotton crossed out.
      Fathoms: fourteen and a half, write 14.5
      Due Friday for the Alden mending. The Retort name on the due line is crossed out.
    TEXT

    JUDGMENT_INPUT = <<~TEXT.strip
      Today is Wednesday 14 October 2026. Friday is 16 October 2026.
      #{TICKET}
    TEXT

    Result = Struct.new(
      :parsed, :probability, :roles, :finish, :input_tokens, :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(MendingTicket)
      answer = chat.ask(TICKET)

      judgment = FridayCall.judge(JUDGMENT_INPUT)

      Result.new(
        parsed: answer.parsed,
        probability: judgment.loft_before_friday.probability,
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
  Multivitamin::Cassettes.play(__dir__, "mending_ticket") do
    result = PortAngelesNetTicket::HandwrittenTicket.conduct
  end

  puts JSON.generate(result.parsed)
  puts "loft_before_friday=#{result.probability}"
end
