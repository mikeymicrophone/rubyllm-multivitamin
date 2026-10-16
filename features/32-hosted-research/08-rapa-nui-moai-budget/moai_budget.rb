# frozen_string_literal: true

# Hosted research · 08 · Rapa Nui moai budget
#
# Teaches:
# - budget_exceeded becomes incomplete; wait returns a usable partial Message.
# - case/in destructures a task receipt and marks max_tokens output for follow-up.

require_relative "../../../support/research"

module RapaNuiMoaiBudget
  module_function

  def conduct
    job = Multivitamin::Research.context.research_later(
      "Compare published coastal erosion monitoring around Rapa Nui moai platforms. " \
      "Separate documented observations from proposed surveys; cite evidence and list unresolved sites.",
      provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH
    ).wait(timeout: 600, interval: Multivitamin::Research.interval)
    receipt = { status: job.status, report: job.message, id: job.id }
    case receipt
    in { status: :incomplete, report:, id: }
      { brief: report.content, follow_up: id, finish_reason: report.finish_reason, complete: false }
    in { status: :completed, report: }
      { brief: report.content, follow_up: nil, finish_reason: report.finish_reason, complete: true }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  receipt = Multivitamin::Cassettes.play(__dir__, "moai_budget") { RapaNuiMoaiBudget.conduct }
  puts receipt.fetch(:brief)
  puts "follow_up=#{receipt.fetch(:follow_up)} complete=#{receipt.fetch(:complete)}"
end
