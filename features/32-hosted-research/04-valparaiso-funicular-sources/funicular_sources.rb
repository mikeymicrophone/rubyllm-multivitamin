# frozen_string_literal: true

# Hosted research · 04 · Valparaíso funicular sources
#
# Teaches:
# - A scoped refinement formats Citation objects without changing the gem globally.
# - each_with_object groups sources; UTF-8 citation byte offsets become character spans.

require_relative "../../../support/research"

module ValparaisoFunicularSources
  module SourceLabels
    refine RubyLLM::Citation do
      def source_label = "#{title}: #{url}"
    end
  end
  using SourceLabels

  module_function

  def conduct
    report = Multivitamin::Research.context.research(
      "Write a source-led conservation note on Valparaíso's historic funiculars. " \
      "Distinguish heritage significance from operating status; do not promise service today.",
      provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH,
      provider_tools: [:web_search], timeout: 600, interval: Multivitamin::Research.interval
    )
    sources = report.citations.each_with_object({}) do |citation, ledger|
      (ledger[citation.url] ||= []) << citation.source_label
    end
    { report: report, sources: sources }
  end
end

if $PROGRAM_NAME == __FILE__
  ledger = Multivitamin::Cassettes.play(__dir__, "funicular_sources") { ValparaisoFunicularSources.conduct }
  puts ledger.fetch(:report).content
  puts ledger.fetch(:sources).values.flatten
end
