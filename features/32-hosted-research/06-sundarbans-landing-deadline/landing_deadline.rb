# frozen_string_literal: true

# Hosted research · 06 · Sundarbans landing deadline
#
# Teaches:
# - job.wait timeout retains the independent pending job through error.job.
# - An instance separates submission, collection, and recovery; rescue does not cancel.

require_relative "../../../support/research"

module SundarbansLandingDeadline
  Collection = Data.define(:job, :report, :timed_out)

  class LandingDesk
    def submit
      @job = Multivitamin::Research.context.research_later(
        "Research raised passenger landings in the Sundarbans. Compare mangrove protection " \
        "with cyclone access needs; identify evidence gaps before proposing a monitoring plan.",
        provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH
      )
    end

    def collect(timeout: 600, interval: Multivitamin::Research.interval)
      @job.wait(timeout: timeout, interval: interval)
      Collection.new(@job, @job.message.content, false)
    rescue RubyLLM::ResearchJob::TimeoutError => deadline
      Collection.new(deadline.job, nil, true)
    end

    def recover
      @job.wait(timeout: 600, interval: Multivitamin::Research.interval).message.content
    end
  end
end

if $PROGRAM_NAME == __FILE__
  collection = Multivitamin::Cassettes.play(__dir__, "landing_deadline") do
    desk = SundarbansLandingDeadline::LandingDesk.new
    desk.submit
    desk.collect
  end
  puts collection.report || "Recover pending landing study #{collection.job.id}"
end
