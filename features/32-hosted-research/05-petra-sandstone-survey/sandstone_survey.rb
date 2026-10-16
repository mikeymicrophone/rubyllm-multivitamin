# frozen_string_literal: true

# Hosted research · 05 · Petra sandstone survey
#
# Teaches:
# - with: attaches a local PDF inline as a document, not as a prompt filename.
# - A customized Data record pairs file citations and page numbers with a report.

require_relative "../../../support/research"

module PetraSandstoneSurvey
  Survey = Data.define(:report, :pages) do
    def page_labels = pages.map { |page| "survey page #{page}" }
  end
  SURVEY = File.expand_path("fixtures/sandstone-survey.pdf", __dir__)

  module_function

  def conduct
    report = Multivitamin::Research.context.research(
      "Use the attached Petra sandstone survey to prioritize monitoring at the Siq. " \
      "Separate the supplied observations from any external conservation advice and cite the survey page.",
      provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH,
      with: SURVEY, provider_tools: [], timeout: 600, interval: Multivitamin::Research.interval
    )
    Survey.new(report.content, report.citations.filter_map(&:start_page).uniq)
  end
end

if $PROGRAM_NAME == __FILE__
  survey = Multivitamin::Cassettes.play(__dir__, "sandstone_survey") { PetraSandstoneSurvey.conduct }
  puts survey.report
  puts survey.page_labels
end
