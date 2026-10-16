# frozen_string_literal: true

# OpenTelemetry · 13 · Samarkand Registan trace desk
#
# Teaches:
# - An Agent declares model, tools, instructions, and a structured-output schema.
# - A table of turns and an explicit generate/run_tools loop expose model boundaries.
# - Workflow steps, tool spans, JSON output type, usage, and transcript history meet in one trace.

require "json"
require_relative "../../../support/tracing"

module SamarkandRegistanTraceDesk
  class TileCart < RubyLLM::Tool
    description "Reads the posted Registan conservation tile cart"
    def self.tool_name = "tile_cart"
    def execute = { tile_crates: 8, keeper: "Dilshod", unload: "08:25" }
  end

  class DispatchCard < Schematist::Schema
    title "registan_dispatch"
    string :keeper
    integer :tile_crates
    string :unload
  end

  class ConservationClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools TileCart
    schema DispatchCard
    instructions "You are the Registan conservation clerk. Read tile_cart for the first dispatch. Keep its keeper and crate count on later turns; change only an explicitly revised unloading time."
  end

  TURNS = [
    ["Read tile cart", "Read the tile cart and issue the first dispatch."],
    ["Revise unloading", "The Registan loading crew moves unloading to 08:50. Issue the revised dispatch with the same keeper and crate count."]
  ].freeze

  def self.conduct
    Multivitamin::Runtime.configure(provider: :openai)
    Multivitamin::Tracing.capture do
      RubyLLM.workflow("Conservation dispatch", id: "conservation-dispatch") do |workflow|
        chat = ConservationClerk.chat
        chat.with_tool_options(choice: TileCart)
        cards = TURNS.map do |step_name, question|
          workflow.step(step_name) do
            chat.ask_later(question)
            until chat.complete?
              chat.generate
              chat.run_tools if chat.messages.last.tool_call?
            end
            chat.messages.last.parsed
          end
        end
        { cards: cards, roles: chat.messages.map(&:role), tokens: chat.tokens }
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  capture = Multivitamin::Cassettes.play(__dir__, "registan_desk") do
    SamarkandRegistanTraceDesk.conduct
  end
  puts capture.value.inspect
  puts capture.spans.map(&:name)
end
