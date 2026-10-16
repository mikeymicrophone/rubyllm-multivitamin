# frozen_string_literal: true

# Tokens and cost · 09 · Cochabamba market tenant tallies
#
# Teaches:
# - RubyLLM.with_usage_owner attributes each chat's attempts.
# - Cost.aggregate sums two messages.
# - Two tenants keep separate chat.cost totals.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CochabambaMarketTenants
  Tenant = Struct.new(:name, keyword_init: true)

  # The llajwa mill and the salteña oven each file one question on their
  # own chat. The overnight desk tallies them as two tenants, then
  # aggregates the costs.
  class MarketTenants
    MILL = Tenant.new(name: "La Cancha llajwa mill")
    OVEN = Tenant.new(name: "La Cancha salteña oven")

    MILL_INSTRUCTIONS = <<~TEXT.strip
      You are the mill clerk at the llajwa stall in La Cancha, Cochabamba.
      Answer in one short sentence.
      Use only the mill card in the question.
      Name stall LC-4 and 42 bottles.
      Do not invent a heat.
    TEXT

    MILL_QUESTION = <<~TEXT.strip
      La Cancha llajwa mill, stall LC-4, Friday 16 October 2026, 06:50.
      Market page: https://www.cochabamba.gob.bo/
      42 bottles of llajwa, 1,050 pesos, locoto 51 on the grind.
      The cart Cancha is alongside.
      How many bottles on stall LC-4?
    TEXT

    OVEN_INSTRUCTIONS = <<~TEXT.strip
      You are the oven clerk at the salteña stall in La Cancha, Cochabamba.
      Answer in one short sentence.
      Use only the oven board in the question.
      Name the 07:30 first tray and 28 salteñas.
      Do not invent a filling.
    TEXT

    OVEN_QUESTION = <<~TEXT.strip
      La Cancha salteña oven board, Friday 16 October 2026, 07:05.
      City notes: https://www.cochabamba.gob.bo/
      28 salteñas on the first tray. The 07:30 first tray is held.
      Is the 07:30 first tray held, and how many salteñas sit on the board?
    TEXT

    Result = Struct.new(
      :mill_brief,
      :oven_brief,
      :mill_cost,
      :oven_cost,
      :aggregated_cost,
      :mill_input,
      :oven_input,
      :mill_owner,
      :oven_owner,
      keyword_init: true
    )

    def self.conduct
      configure

      mill_chat = nil
      mill_message = nil
      RubyLLM.with_usage_owner(MILL) do
        mill_chat = open_chat
        mill_chat.with_instructions(MILL_INSTRUCTIONS)
        mill_chat.with_temperature(0.2)
        mill_message = mill_chat.ask(MILL_QUESTION)
      end

      oven_chat = nil
      oven_message = nil
      RubyLLM.with_usage_owner(OVEN) do
        oven_chat = open_chat
        oven_chat.with_instructions(OVEN_INSTRUCTIONS)
        oven_chat.with_temperature(0.2)
        oven_message = oven_chat.ask(OVEN_QUESTION)
      end

      Result.new(
        mill_brief: mill_message.content,
        oven_brief: oven_message.content,
        mill_cost: mill_chat.cost.total,
        oven_cost: oven_chat.cost.total,
        aggregated_cost: RubyLLM::Cost.aggregate([mill_message.cost, oven_message.cost]).total,
        mill_input: mill_chat.tokens.input,
        oven_input: oven_chat.tokens.input,
        mill_owner: mill_chat.usage_entries.map(&:owner).uniq,
        oven_owner: oven_chat.usage_entries.map(&:owner).uniq
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
  Multivitamin::Cassettes.play(__dir__, "market_tenants") do
    result = CochabambaMarketTenants::MarketTenants.conduct
  end

  puts "mill (#{result.mill_owner.map(&:name).join}): #{result.mill_brief}"
  puts "oven (#{result.oven_owner.map(&:name).join}): #{result.oven_brief}"
  puts "costs mill=#{result.mill_cost.inspect} oven=#{result.oven_cost.inspect} " \
       "aggregate=#{result.aggregated_cost.inspect}"
end
