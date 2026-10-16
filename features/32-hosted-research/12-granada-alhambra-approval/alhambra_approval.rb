# frozen_string_literal: true

# Hosted research · 12 · Granada Alhambra approval
#
# Teaches:
# - Vertex research rejects MCP approval options and unsupported provider options before HTTP.
# - A table of requests and keyword forwarding keep local validation failures inspectable.

require_relative "../../../support/research"

module GranadaAlhambraApproval
  QUESTION = "Research queue management for Alhambra timed-entry tickets in Granada; cite official guidance."
  RESTRICTIONS = {
    approval: { provider_tools: { mcp: { name: "learn", url: "https://learn.microsoft.com/api/mcp",
                                       require_approval: "always" } } },
    generation: { provider_options: { max_output_tokens: 1024 } }
  }.freeze

  module_function

  def conduct
    context = Multivitamin::Research.context
    RESTRICTIONS.to_h do |policy, options|
      refusal = begin
        context.research_later(QUESTION, provider: :vertexai,
                               agent: Multivitamin::Models::VERTEXAI_RESEARCH, **options)
        raise "Alhambra #{policy} restriction unexpectedly accepted"
      rescue ArgumentError => error
        error.message
      end
      [policy, refusal]
    end
  end
end

if $PROGRAM_NAME == __FILE__
  refusals = GranadaAlhambraApproval.conduct
  refusals.each { |policy, refusal| puts "#{policy}: #{refusal}" }
end
