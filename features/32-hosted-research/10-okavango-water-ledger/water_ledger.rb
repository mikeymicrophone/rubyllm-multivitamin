# frozen_string_literal: true

# Hosted research · 10 · Okavango water ledger
#
# Teaches:
# - Agent usage does not borrow inference-model pricing; unknown cost stays nil.
# - zip, sum, and numbered parameters build a ledger without double-counting thoughts.

require_relative "../../../support/research"

module OkavangoWaterLedger
  module_function

  def conduct
    job = Multivitamin::Research.context.research_later(
      "Research the provenance of Okavango Delta seasonal flood maps. " \
      "Compare satellite and ground observations, retain publication dates, and flag gaps in coverage.",
      provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH
    ).wait(timeout: 600, interval: Multivitamin::Research.interval)
    counts = [job.tokens.input, job.tokens.output, job.tokens.thinking]
    buckets = %i[input output thinking].zip(counts).to_h
    { report: job.message.content, buckets: buckets,
      billed_tokens: counts.take(2).sum { _1 || 0 },
      cost: job.cost.total, message_cost: job.message.cost.total,
      agent: job.agent }
  end
end

if $PROGRAM_NAME == __FILE__
  ledger = Multivitamin::Cassettes.play(__dir__, "water_ledger") { OkavangoWaterLedger.conduct }
  puts ledger.fetch(:report)
  puts "tokens=#{ledger.fetch(:billed_tokens)} cost=#{ledger.fetch(:cost).inspect}"
end
