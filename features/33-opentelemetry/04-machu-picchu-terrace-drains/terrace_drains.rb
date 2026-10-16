# frozen_string_literal: true

# OpenTelemetry · 04 · Machu Picchu terrace drains
#
# Teaches:
# - A table drives nested workflow steps with stable safe IDs.
# - each_with_object builds a repair ledger; step returns the block value.
# - Trace and parent IDs describe the tree independently of finish order.

require "json"
require_relative "../../../support/tracing"

module MachuPicchuTerraceDrains
  DRAINS = [["Upper terrace", 3], ["Lower terrace", 2]].freeze

  def self.conduct
    Multivitamin::Tracing.capture do
      RubyLLM.workflow("Terrace drainage", id: "terrace-drainage") do |workflow|
        DRAINS.each_with_object({}) do |(terrace, blocked), ledger|
          ledger[terrace] = workflow.step(terrace, id: terrace.downcase.tr(" ", "-")) do
            workflow.step("Clear outlets") { blocked * 2 }
          end
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "terrace_drains") do
    MachuPicchuTerraceDrains.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
