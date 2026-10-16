# frozen_string_literal: true

# Hosted research · 11 · Lalibela roof recovery
#
# Teaches:
# - ResearchJob.find recovers a saved remote ID in the original provider context.
# - JSON receipt destructuring and a lazy citation pipeline avoid a second submission.

require_relative "../../../support/research"

require "json"

module LalibelaRoofRecovery
  RECEIPT = File.expand_path("fixtures/roof-receipt.json", __dir__)

  module_function

  def conduct(receipt_path: RECEIPT)
    receipt = JSON.parse(File.read(receipt_path), symbolize_names: true)
    receipt => { job_id:, provider: "vertexai" }
    job = RubyLLM::ResearchJob.find(job_id, provider: :vertexai, context: Multivitamin::Research.context)
    job.wait(timeout: 600, interval: Multivitamin::Research.interval)
    sources = job.message.citations.lazy.map(&:url).reject(&:nil?).uniq.take(3).force
    { id: job.id, report: job.message.content, sources: sources, status: job.status }
  end
end

if $PROGRAM_NAME == __FILE__
  recovered = Multivitamin::Cassettes.play(__dir__, "roof_recovery") do
    LalibelaRoofRecovery.conduct(receipt_path: ARGV.first || LalibelaRoofRecovery::RECEIPT)
  end
  puts recovered.fetch(:report)
  puts recovered.fetch(:id)
end
