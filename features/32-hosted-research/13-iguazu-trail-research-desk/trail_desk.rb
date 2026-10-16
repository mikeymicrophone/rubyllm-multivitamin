# frozen_string_literal: true

# Hosted research · 13 · Iguazú trail research desk
#
# Teaches:
# - A capstone submits a table of tasks, waits, and retains IDs for failed work.
# - Data records, &method(:collect), find patterns, and source grouping build a desk handover.

require_relative "../../../support/research"

module IguazuTrailResearchDesk
  Study = Data.define(:bank, :question)
  Handover = Data.define(:reports, :sources, :tokens, :jobs)
  STUDIES = [
    Study.new(:argentina, "Research documented flood closures on Iguazú National Park trails in Argentina. " \
                         "Separate historical damage from present access; cite the national park authority."),
    Study.new(:brazil, "Research accessible viewing routes at Iguaçu National Park in Brazil. " \
                      "Distinguish published accessibility guidance from current closure notices; cite official sources.")
  ].freeze

  class TrailDesk
    attr_reader :jobs

    def conduct
      @context = Multivitamin::Research.context
      @jobs = STUDIES.map do |study|
        @context.research_later(study.question, provider: :vertexai,
                               agent: Multivitamin::Models::VERTEXAI_RESEARCH, provider_tools: [:web_search])
      end
      reports = STUDIES.map(&:bank).zip(jobs.map(&method(:collect))).to_h
      sources = reports.values.flat_map(&:citations).group_by(&:url).transform_values { |citations| citations.map(&:title).uniq }
      tokens = jobs.sum { |job| job.tokens.input.to_i + job.tokens.output.to_i }
      Handover.new(reports, sources, tokens, jobs.map(&:id))
    end

    def collect(job)
      job.wait(timeout: 600, interval: Multivitamin::Research.interval).message
    rescue RubyLLM::ResearchJob::Error => failure
      raise "Trail research #{failure.job.id} ended #{failure.job.status}: #{failure.job.error}; " \
            "recover jobs: #{jobs.map(&:id).join(', ')}"
    end

    def self.search_performed?(report)
      case report.server_tool_calls.map(&:type)
      in [*, "google_search_call", *] then true
      else false
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  handover = Multivitamin::Cassettes.play(__dir__, "trail_desk") { IguazuTrailResearchDesk::TrailDesk.new.conduct }
  handover.reports.each { |bank, report| puts "#{bank}: #{report.content}" }
  puts "tokens=#{handover.tokens} jobs=#{handover.jobs.join(', ')}"
end
