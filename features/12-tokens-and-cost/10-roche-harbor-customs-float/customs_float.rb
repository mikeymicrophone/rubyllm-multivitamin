# frozen_string_literal: true

# Tokens and cost · 10 · Roche Harbor customs-float unpriced clerk
#
# Teaches:
# - An assumed model with no registry prices cannot estimate a cost.
# - Tokens that carry reported_cost still give that number to cost_for.
# - Tokens built with only input and output yield nil on that clerk.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RocheHarborCustomsFloat
  # The customs clerk at Roche Harbor files the morning declaration for
  # the ketch Spieden, then prices those tokens on an unlisted clerk who
  # is not in the registry.
  class CustomsFloat
    UNLISTED = "roche-harbor-customs-clerk-unlisted"

    INSTRUCTIONS = <<~TEXT.strip
      You are the customs clerk at the Roche Harbor float, north San Juan Island.
      Answer in two short sentences.
      Use only the declaration in the question.
      Name the ketch Spieden and 06:40.
      Do not invent a crew count.
    TEXT

    DECLARATION_QUESTION = <<~TEXT.strip
      Roche Harbor customs declaration, Wednesday 14 October 2026, 06:40.
      Port page: https://www.rocheharbor.com/
      CBP notes: https://www.cbp.gov/
      Ketch Spieden, Friday Harbor to Roche Harbor, crew 3, no commercial cargo.
      The skipper is waiting at the customs float under the Union Jack.
      When did Spieden arrive, and is there cargo?
    TEXT

    Result = Struct.new(
      :brief,
      :live_cost,
      :live_reported,
      :unlisted_id,
      :unlisted_warning,
      :unlisted_input_price,
      :priced_with_reported,
      :priced_bare,
      :input_tokens,
      :output_tokens,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(DECLARATION_QUESTION)

      unlisted = RubyLLM.chat(model: UNLISTED, provider: :openai, assume_model_exists: true)
      work = RubyLLM::Tokens.new(input: brief.tokens.input, output: brief.tokens.output)

      Result.new(
        brief: brief.content,
        live_cost: brief.cost.total,
        live_reported: brief.tokens.reported_cost,
        unlisted_id: unlisted.model.id,
        unlisted_warning: unlisted.model.metadata[:warning],
        unlisted_input_price: unlisted.model.price(:input),
        priced_with_reported: unlisted.model.cost_for(brief.tokens).total,
        priced_bare: unlisted.model.cost_for(work).total,
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
  Multivitamin::Cassettes.play(__dir__, "customs_float") do
    result = RocheHarborCustomsFloat::CustomsFloat.conduct
  end

  puts result.brief
  puts "live=#{result.live_cost.inspect} with_reported=#{result.priced_with_reported.inspect} " \
       "bare=#{result.priced_bare.inspect} price=#{result.unlisted_input_price.inspect}"
end
