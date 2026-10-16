# frozen_string_literal: true

# Hosted research · 03 · Nairobi railway archive
#
# Teaches:
# - A context submits hosted MCP research; name and url remain Vertex MCP fields.
# - A proc builds a documentation brief; remote calls appear on server_tool_calls.

require_relative "../../../support/research"

module NairobiRailwayArchive
  BRIEF = proc do |archive, retention|
    "Research an Azure Functions ingestion design for #{archive}. " \
      "Compare Blob triggers with queue retries; preserve #{retention} and cite Microsoft Learn."
  end

  module_function

  def conduct
    Multivitamin::Research.context.research(
      BRIEF.call("Nairobi Railway Museum's scanned carriage registers", "original scan provenance"),
      provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH,
      provider_tools: { mcp: { name: "learn", url: "https://learn.microsoft.com/api/mcp" } },
      timeout: 600, interval: Multivitamin::Research.interval
    ).then do |report|
      { brief: report.content, tools: report.server_tool_calls.map(&:name).compact,
        sources: report.citations.map(&:url) }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  archive = Multivitamin::Cassettes.play(__dir__, "railway_archive") { NairobiRailwayArchive.conduct }
  puts archive.fetch(:brief)
  puts archive.fetch(:tools)
end
