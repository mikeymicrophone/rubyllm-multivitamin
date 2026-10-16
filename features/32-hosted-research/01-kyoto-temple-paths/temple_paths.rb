# frozen_string_literal: true

# Hosted research · 01 · Kyoto temple paths
#
# Teaches:
# - Blocking research returns a Message, with a hosted agent rather than a model.
# - Data.define records and module functions turn a cited report into a route card.

require_relative "../../../support/research"

module KyotoTemplePaths
  RouteCard = Data.define(:report, :sources, :thinking, :tokens)
  QUESTION = <<~TEXT.strip
    Prepare a conservation briefing for the Philosopher's Path in Kyoto.
    Compare official advice for Nanzen-ji and Ginkaku-ji approaches, separating
    public walking paths from temple grounds. Cite sources for access guidance;
    flag seasonal uncertainty rather than inventing current opening hours.
  TEXT

  module_function

  def conduct
    context = Multivitamin::Research.context
    report = RubyLLM.research(
      QUESTION, provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH,
      context: context, provider_tools: [:web_search],
      timeout: 600, interval: Multivitamin::Research.interval
    )
    RouteCard.new(report.content, report.citations.map(&:url), report.thinking&.text, report.tokens)
  end
end

if $PROGRAM_NAME == __FILE__
  card = Multivitamin::Cassettes.play(__dir__, "temple_paths") { KyotoTemplePaths.conduct }
  puts card.report
  puts card.sources
end
