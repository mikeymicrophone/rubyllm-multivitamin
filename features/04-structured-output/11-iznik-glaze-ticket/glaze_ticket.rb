# frozen_string_literal: true

# Structured output · 11 · Iznik glaze ticket
#
# Teaches:
# - Field descriptions steer the model when the ticket is messy: which
#   kiln, which glaze, which bowl count, and who the firing is for.
# - A Judge probability is the Decisions form of a yes/no. RubyLLM sends
#   it as a predicate question and reads probability between 0 and 1.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module IznikGlazeTicket
  class GlazeTicket < Schematist::Schema
    title "glaze_ticket"
    description "A handwritten glaze ticket from the Iznik tile workshop"

    string :kiln, description: "The kiln named on the ticket. Not the workshop, and not a kiln that was crossed out."
    string :glaze, description: "The glaze that is still wanted. Ignore a colour marked not or crossed out."
    number :bowls, description: "Bowl count as a number"
    string :due_for, description: "Who the firing is for. Ignore a name that was crossed out."
  end

  class FridayCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    probability :kiln_before_friday,
                "Does this firing have to be in the kiln before Friday? Yes when the ticket is due Friday or sooner."
  end

  class HandwrittenTicket
    INSTRUCTIONS = <<~TEXT.strip
      You are the glaze clerk at the Iznik tile workshop.
      Fill glaze_ticket from the handwritten ticket.
      Trust the field descriptions when the handwriting contradicts itself.
    TEXT

    TICKET = <<~TEXT.strip
      Handwritten, Iznik tile workshop, Wednesday 14 October 2026.
      Workshop: https://whc.unesco.org/en/list/849
      Kiln: Çini 4. (the red kiln. not the workshop. Osman was written then crossed out.)
      Glaze Iznik red — NOT the cobalt, cobalt crossed out.
      Bowls: fourteen and a half, write 14.5
      Due Friday for the Hatice firing. The Osman name on the due line is crossed out.
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
      chat.with_schema(GlazeTicket)
      answer = chat.ask(TICKET)

      judgment = FridayCall.judge(JUDGMENT_INPUT)

      Result.new(
        parsed: answer.parsed,
        probability: judgment.kiln_before_friday.probability,
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
  Multivitamin::Cassettes.play(__dir__, "glaze_ticket") do
    result = IznikGlazeTicket::HandwrittenTicket.conduct
  end

  puts JSON.generate(result.parsed)
  puts "kiln_before_friday=#{result.probability}"
end
