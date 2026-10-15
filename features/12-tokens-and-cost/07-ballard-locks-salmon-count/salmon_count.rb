# frozen_string_literal: true

# Tokens and cost · 07 · Ballard Locks salmon-count reported price
#
# Teaches:
# - cost.total is the provider's usage.cost when one is present.
# - Component costs still come from the registry. An assumed free slug
#   has none, so cost.input stays nil while total is the reported 0.
# - cost_for on gpt-4.1-mini, using Tokens without reported_cost, is a
#   registry estimate for the same work.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BallardLocksSalmonCount
  # The count clerk at the Hiram M. Chittenden Locks files the morning
  # sockeye window, then compares the reported cost with a registry
  # estimate for the same token work.
  class SalmonCount
    INSTRUCTIONS = <<~TEXT.strip
      You are the fish-count clerk at the Hiram M. Chittenden Locks in Ballard.
      Answer in two short sentences.
      Use only the count board in the question.
      Name 86 sockeye and ladder 1.
      Do not invent a chinook figure.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Ballard Locks fish-count board, Wednesday 14 October 2026, 07:15.
      Corps page: https://www.nws.usace.army.mil/Missions/Civil-Works/Locks-and-Dams/Chittenden-Locks/
      Ladder 1, morning window 06:00 to 07:00: 86 sockeye, 12 coho, 0 chinook.
      The large lock is holding the tug Salmon Bay for a 07:30 southbound.
      How many sockeye on ladder 1, and is chinook zero?
    TEXT

    Result = Struct.new(
      :brief,
      :cost_total,
      :cost_input,
      :cost_output,
      :reported_cost,
      :registry_mini_total,
      :unlisted_with_reported,
      :bare_unlisted_total,
      :input_tokens,
      :output_tokens,
      keyword_init: true
    )

    UNLISTED = "ballard-locks-salmon-clerk-unlisted"

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(BOARD_QUESTION)

      work = RubyLLM::Tokens.new(input: brief.tokens.input, output: brief.tokens.output)
      mini = RubyLLM.models.find("gpt-4.1-mini", provider: :openai)
      unlisted = RubyLLM::Model.default(UNLISTED, "openai")

      Result.new(
        brief: brief.content,
        cost_total: brief.cost.total,
        cost_input: brief.cost.input,
        cost_output: brief.cost.output,
        reported_cost: brief.tokens.reported_cost,
        registry_mini_total: mini.cost_for(work).total,
        unlisted_with_reported: unlisted.cost_for(brief.tokens).total,
        bare_unlisted_total: unlisted.cost_for(work).total,
        input_tokens: brief.tokens.input,
        output_tokens: brief.tokens.output
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
  Multivitamin::Cassettes.play(__dir__, "salmon_count") do
    result = BallardLocksSalmonCount::SalmonCount.conduct
  end

  puts result.brief
  puts "reported=#{result.reported_cost.inspect} total=#{result.cost_total.inspect} " \
       "input=#{result.cost_input.inspect} mini=#{result.registry_mini_total.inspect} " \
       "bare_unlisted=#{result.bare_unlisted_total.inspect}"
end
