# frozen_string_literal: true

# Hosted research · 07 · Reykjavík heat cancel
#
# Teaches:
# - cancel requests a remote transition; cancelled message raises an error retaining the job.
# - A lambda captures an audit snapshot before and after provider confirmation.

require_relative "../../../support/research"

module ReykjavikHeatCancel
  SNAPSHOT = ->(job) { { id: job.id, status: job.status, pending: job.pending? }.freeze }

  module_function

  def conduct
    job = Multivitamin::Research.context.research_later(
      "Research archive sources for Reykjavík district heating pipe replacement. " \
      "Compare historical network maps with public maintenance reports and cite each source.",
      provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH
    )
    before = SNAPSHOT.call(job)
    job.cancel
    after = SNAPSHOT.call(job)
    cancellation_error = begin
      job.message
      nil
    rescue RubyLLM::ResearchJob::Error => cancellation
      cancellation
    end
    { before: before, after: after, cancelled: job.cancelled?, error: cancellation_error }
  end
end

if $PROGRAM_NAME == __FILE__
  audit = Multivitamin::Cassettes.play(__dir__, "heat_cancel") { ReykjavikHeatCancel.conduct }
  puts audit.fetch(:before)
  puts audit.fetch(:after)
end
