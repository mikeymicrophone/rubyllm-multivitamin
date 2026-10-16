# frozen_string_literal: true

# Tokens and cost · 03 · Bahir Dar teff-mill totals
#
# Teaches:
# - chat.tokens sums every attempt on that chat.
# - With no retries, chat.tokens.input equals the sum of the two replies.
# - A second ask grows the input count because the first turn goes back.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BahirDarTeffMill
  # The mill clerk at Bahir Dar logs the morning teff count, then answers
  # a second hail about the closed yard gate. Both turns sit on one chat,
  # and the desk reads the summed tokens.
  class TeffMill
    INSTRUCTIONS = <<~TEXT.strip
      You are the mill clerk at the teff mill on the Bahir Dar lakeshore.
      Keep each reply to two short sentences.
      Use only the count card in this chat.
      Name teff sacks and 1,240.
      Do not invent a gate time.
    TEXT

    COUNT_QUESTION = <<~TEXT.strip
      Morning teff card, Bahir Dar lakeshore mill, Friday 16 October 2026, 06:20.
      Mill notes: https://www.amhara.gov.et/
      Teff sacks on the floor count: 1,240.
      The yard gate is closed to the public until 09:00 for the count.
      The cart Tana is standing off with the weigh crew.
      How many teff sacks, and is the gate closed?
    TEXT

    GATE_QUESTION = "Tana wants to put two extra weighers through the yard gate before 09:00. May they enter?"

    Result = Struct.new(
      :count_brief,
      :gate_brief,
      :opening_input,
      :follow_up_input,
      :chat_input,
      :chat_output,
      :chat_cost,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      opening = chat.ask(COUNT_QUESTION)
      follow_up = chat.ask(GATE_QUESTION)

      Result.new(
        count_brief: opening.content,
        gate_brief: follow_up.content,
        opening_input: opening.tokens.input,
        follow_up_input: follow_up.tokens.input,
        chat_input: chat.tokens.input,
        chat_output: chat.tokens.output,
        chat_cost: chat.cost.total,
        roles: chat.messages.map(&:role)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "teff_mill") do
    result = BahirDarTeffMill::TeffMill.conduct
  end

  puts result.count_brief
  puts
  puts result.gate_brief
  puts "chat in=#{result.chat_input} opening=#{result.opening_input} follow=#{result.follow_up_input}"
end
