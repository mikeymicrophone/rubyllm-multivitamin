# frozen_string_literal: true

# Tokens and cost · 10 · Lahore truck-art unpriced clerk
#
# Teaches:
# - An assumed model with no registry prices cannot estimate a cost.
# - Tokens that carry reported_cost still give that number to cost_for.
# - Tokens built with only input and output yield nil on that clerk.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LahoreTruckArtClerk
  # The paint clerk at the Lahore truck yard files the morning card for
  # the Bedford Sohni Dharti, then prices those tokens on an unlisted
  # clerk who is not in the registry.
  class TruckArt
    UNLISTED = "lahore-truck-art-clerk-unlisted"

    INSTRUCTIONS = <<~TEXT.strip
      You are the paint clerk at the truck-art yard on Multan Road, Lahore.
      Answer in two short sentences.
      Use only the paint card in the question.
      Name the Bedford Sohni Dharti and 06:40.
      Do not invent a crew count.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Lahore truck-art card, Friday 16 October 2026, 06:40.
      Yard notes: https://www.lahore.gop.pk/
      Craft board: https://www.punjab.gov.pk/
      Bedford Sohni Dharti, Multan Road to the Badami Bagh yard, painters 3, no commercial cargo of goods.
      The driver is waiting under the peacock panel.
      When did Sohni Dharti arrive, and is there cargo?
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
      brief = chat.ask(CARD_QUESTION)

      unlisted = RubyLLM::Model.default(UNLISTED, "openai")
      work = RubyLLM::Tokens.new(input: brief.tokens.input, output: brief.tokens.output)

      Result.new(
        brief: brief.content,
        live_cost: brief.cost.total,
        live_reported: brief.tokens.reported_cost,
        unlisted_id: unlisted.id,
        unlisted_warning: unlisted.metadata[:warning],
        unlisted_input_price: unlisted.price(:input),
        priced_with_reported: unlisted.cost_for(brief.tokens).total,
        priced_bare: unlisted.cost_for(work).total,
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
  Multivitamin::Cassettes.play(__dir__, "truck_art") do
    result = LahoreTruckArtClerk::TruckArt.conduct
  end

  puts result.brief
  puts "live=#{result.live_cost.inspect} with_reported=#{result.priced_with_reported.inspect} " \
       "bare=#{result.priced_bare.inspect} price=#{result.unlisted_input_price.inspect}"
end
