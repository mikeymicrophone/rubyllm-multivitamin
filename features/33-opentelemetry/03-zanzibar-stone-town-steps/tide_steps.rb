# frozen_string_literal: true

# OpenTelemetry · 03 · Zanzibar Stone Town tide steps
#
# Teaches:
# - Class and instance tools share registration; a block declares the tide schema.
# - ask_later, generate, then run_tools deliberately stop before another ask.
# - execute_tool is an internal child of the active workflow step, beside chat.

require "json"
require_relative "../../../support/tracing"

module ZanzibarStoneTownSteps
  class LandingTide < RubyLLM::Tool
    description "Reads the posted landing tide at Stone Town"
    def self.tool_name = "landing_tide"
    parameters do
      string :landing, description: "The named Stone Town landing"
    end
    def execute(landing:) = { landing: landing, clearance_cm: 45, keeper: "Asha" }
  end

  class StepRope < RubyLLM::Tool
    description "Reads the spare rope length at Stone Town"
    def self.tool_name = "step_rope"
    def execute = { rope_metres: 12 }
  end

  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    Multivitamin::Tracing.capture do
      RubyLLM.workflow("Landing inspection", id: "landing-inspection") do |workflow|
        workflow.step("Read landing card", id: "landing-card") do
          chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
          chat.with_tools(LandingTide, StepRope.new)
          chat.with_tool_options(choice: LandingTide)
          chat.ask_later("Read the posted tide for Forodhani steps. Leave the landing decision to Asha.")
          chat.generate
          chat.run_tools
          { roles: chat.messages.map(&:role), card: JSON.parse(chat.messages.last.content) }
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "tide_steps") do
    ZanzibarStoneTownSteps.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
