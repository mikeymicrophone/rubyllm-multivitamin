# frozen_string_literal: true

# Tokens and cost · 09 · Penn Cove mussel-raft tenant tallies
#
# Teaches:
# - RubyLLM.with_usage_owner attributes each chat's attempts.
# - Cost.aggregate sums two messages.
# - Two tenants keep separate chat.cost totals.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PennCoveMusselRaft
  Tenant = Struct.new(:name, keyword_init: true)

  # The Coupeville ferry dock and the Penn Cove mussel raft each file one
  # question on their own chat. The overnight desk tallies them as two
  # tenants, then aggregates the costs.
  class MusselRaft
    RAFT = Tenant.new(name: "Penn Cove mussel raft")
    DOCK = Tenant.new(name: "Coupeville ferry dock")

    RAFT_INSTRUCTIONS = <<~TEXT.strip
      You are the harvest clerk on the Penn Cove mussel raft off Coupeville.
      Answer in one short sentence.
      Use only the harvest card in the question.
      Name raft PC-4 and 42 sacks.
      Do not invent a temperature.
    TEXT

    RAFT_QUESTION = <<~TEXT.strip
      Penn Cove mussel harvest, raft PC-4, Wednesday 14 October 2026, 06:50.
      Island County page: https://www.islandcountywa.gov/
      42 sacks of mussels, 1,050 pounds, water 51 F.
      The skiff Penn is alongside.
      How many sacks on raft PC-4?
    TEXT

    DOCK_INSTRUCTIONS = <<~TEXT.strip
      You are the slip clerk at the Coupeville ferry dock on Penn Cove.
      Answer in one short sentence.
      Use only the wind board in the question.
      Name the 07:30 Keystone sailing and 28 knots.
      Do not invent a gust.
    TEXT

    DOCK_QUESTION = <<~TEXT.strip
      Coupeville ferry dock wind board, Wednesday 14 October 2026, 07:05.
      WSF page: https://wsdot.wa.gov/ferries
      Wind down Penn Cove 28 knots, gust 34.
      The 07:30 Keystone sailing is held.
      Is the 07:30 Keystone held, and what is the wind?
    TEXT

    Result = Struct.new(
      :raft_brief,
      :dock_brief,
      :raft_cost,
      :dock_cost,
      :aggregated_cost,
      :raft_input,
      :dock_input,
      :raft_owner,
      :dock_owner,
      keyword_init: true
    )

    def self.conduct
      configure

      raft_chat = nil
      raft_message = nil
      RubyLLM.with_usage_owner(RAFT) do
        raft_chat = open_chat
        raft_chat.with_instructions(RAFT_INSTRUCTIONS)
        raft_chat.with_temperature(0.2)
        raft_message = raft_chat.ask(RAFT_QUESTION)
      end

      dock_chat = nil
      dock_message = nil
      RubyLLM.with_usage_owner(DOCK) do
        dock_chat = open_chat
        dock_chat.with_instructions(DOCK_INSTRUCTIONS)
        dock_chat.with_temperature(0.2)
        dock_message = dock_chat.ask(DOCK_QUESTION)
      end

      Result.new(
        raft_brief: raft_message.content,
        dock_brief: dock_message.content,
        raft_cost: raft_chat.cost.total,
        dock_cost: dock_chat.cost.total,
        aggregated_cost: RubyLLM::Cost.aggregate([raft_message.cost, dock_message.cost]).total,
        raft_input: raft_chat.tokens.input,
        dock_input: dock_chat.tokens.input,
        raft_owner: raft_chat.usage_entries.map(&:owner).uniq,
        dock_owner: dock_chat.usage_entries.map(&:owner).uniq
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
  Multivitamin::Cassettes.play(__dir__, "mussel_raft") do
    result = PennCoveMusselRaft::MusselRaft.conduct
  end

  puts "raft (#{result.raft_owner.map(&:name).join}): #{result.raft_brief}"
  puts "dock (#{result.dock_owner.map(&:name).join}): #{result.dock_brief}"
  puts "costs raft=#{result.raft_cost.inspect} dock=#{result.dock_cost.inspect} " \
       "aggregate=#{result.aggregated_cost.inspect}"
end
