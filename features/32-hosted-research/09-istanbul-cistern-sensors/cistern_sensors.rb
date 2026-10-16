# frozen_string_literal: true

# Hosted research · 09 · Istanbul cistern sensors
#
# Teaches:
# - allowed_tools constrains hosted MCP discovery; web_search and MCP can coexist.
# - A tool manifest and filter_map retain named remote calls in a fluent pipeline.

require_relative "../../../support/research"

module IstanbulCisternSensors
  ACCESS = [
    { alias: :web_search, options: {} },
    { alias: :mcp, options: { name: "learn", url: "https://learn.microsoft.com/api/mcp",
                             allowed_tools: ["microsoft_docs_search"] } }
  ].freeze

  module_function

  def conduct
    tools = ACCESS.to_h { |entry| [entry.fetch(:alias), entry.fetch(:options)] }
    Multivitamin::Research.context.research_later(
      "Design a humidity-sensor archive for Istanbul's Basilica Cistern using Azure IoT. " \
      "Use Microsoft Learn for retry and retention semantics; distinguish proposed sensor placement " \
      "from heritage authority guidance. Cite both kinds of sources.",
      provider: :vertexai, agent: Multivitamin::Models::VERTEXAI_RESEARCH, provider_tools: tools
    ).wait(timeout: 600, interval: Multivitamin::Research.interval).then do |job|
      calls = job.message.server_tool_calls.filter_map { |call| call.name if call.type.end_with?("_call") }
      { report: job.message.content, calls: calls,
        agent: job.agent, sources: job.message.citations.map(&:url) }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  card = Multivitamin::Cassettes.play(__dir__, "cistern_sensors") { IstanbulCisternSensors.conduct }
  puts card.fetch(:report)
  puts card.fetch(:calls)
end
