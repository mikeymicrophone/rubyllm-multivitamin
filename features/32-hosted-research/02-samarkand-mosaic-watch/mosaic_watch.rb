# frozen_string_literal: true

# Hosted research · 02 · Samarkand mosaic watch
#
# Teaches:
# - An instance owns a research_later job and polls refresh in a bounded loop.
# - An Enumerator records state transitions; pending message is nil and refresh returns self.

require_relative "../../../support/research"

module SamarkandMosaicWatch
  class MosaicWatch
    attr_reader :job, :states, :pending_report

    def initialize
      @context = Multivitamin::Research.context
      @states = []
    end

    def conduct
      @job = @context.research_later(
        "Compare documented mosaic conservation methods at Samarkand's Registan. " \
        "Distinguish salt damage from missing tesserae and cite institutional sources.",
        provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH
      )
      @pending_report = job.message
      @states << job.status
      3.times.each do
        break if job.done?

        job.refresh
        @states << job.status
        sleep Multivitamin::Research.interval if job.pending?
      end
      raise "Mosaic watch still pending; recover #{job.id}" if job.pending?

      self
    end

    def report = job.message.content
  end
end

if $PROGRAM_NAME == __FILE__
  watch = Multivitamin::Cassettes.play(__dir__, "mosaic_watch") { SamarkandMosaicWatch::MosaicWatch.new.conduct }
  puts watch.report
  puts watch.states.join(" -> ")
end
