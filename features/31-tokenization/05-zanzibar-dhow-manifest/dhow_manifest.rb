# frozen_string_literal: true

# Tokenization · 05 · Zanzibar dhow manifest
#
# Teaches:
# - Anthropic counts function tool definitions without executing the tools.
# - with_tools registers a class and a stateful instance together; parameters do declares schemas.
# - each_with_object projects the registered tools into a manifest index.

require_relative "../../../support/runtime"

module ZanzibarDhowManifest
  class BerthLedger < RubyLLM::Tool
    description "Reads the Stone Town dhow berth ledger for a named vessel"
    def self.tool_name = "berth_ledger"
    parameters do
      string :vessel, description: "Dhow name on the Stone Town board"
    end
    def execute(vessel:) = "#{vessel}: berth ZNZ-3 at 06:20"
  end

  class CargoHold < RubyLLM::Tool
    description "Looks up the allowed crate count for a dhow hold"
    def self.tool_name = "cargo_hold"
    parameters do
      string :hold, description: "Hold reference on the loading manifest"
    end
    attr_reader :reads
    def initialize(capacities)
      @capacities = capacities
      @reads = []
    end
    def execute(hold:)
      @reads << hold
      @capacities.fetch(hold)
    end
  end

  module_function

  def conduct
    context = RubyLLM.context { |config| Multivitamin::Runtime.apply(config, provider: :anthropic) }
    cargo = CargoHold.new("ZNZ-H2" => 18)
    chat = context.chat(model: Multivitamin::Models::ANTHROPIC_COUNT, provider: :anthropic)
      .with_instructions("You are Asha's loading clerk at Stone Town. Consult both ledgers before releasing a dhow.")
      .with_tools(BerthLedger, cargo)
      .with_tool_options(choice: :required)
    estimate = chat.count_tokens("Can dhow Mwangaza load 16 spice crates into ZNZ-H2 before its berth window?")
    manifest = chat.tools.each_with_object({}) { |(name, tool), index| index[name] = tool.description }
    { estimate: estimate, manifest: manifest, reads: cargo.reads, roles: chat.messages.map(&:role) }
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "dhow_manifest") do
    ZanzibarDhowManifest.conduct
  end

  puts result.fetch(:manifest).keys
  puts "input estimate=#{result.fetch(:estimate)}; hold reads=#{result.fetch(:reads).length}"
end
