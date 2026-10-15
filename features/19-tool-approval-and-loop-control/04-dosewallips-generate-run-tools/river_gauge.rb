# frozen_string_literal: true

# Tool approval and loop control · 04 · Dosewallips generate then run_tools
#
# Teaches:
# - generate is one model move. It does not run tools.
# - run_tools executes the pending call and does not ask the model again.
# - halt and RubyLLM::Tool::Halt are gone. Stopping after run_tools is
#   how the loop ends on the gauge card.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DosewallipsGenerateRunTools
  class RiverStaff < RubyLLM::Tool
    description "Reads the Dosewallips River staff at the state-park gauge"

    def self.tool_name
      "river_staff"
    end

    CARD = <<~TEXT.strip
      Dosewallips River staff, Thursday 15 October 2026.
      Stage 4.6 ft at the park gauge. The cedar jam is still holding above the fork.
    TEXT

    def self.reset!
      @read = false
    end

    def self.read?
      @read == true
    end

    def execute
      self.class.instance_variable_set(:@read, true)
      CARD
    end
  end

  class ParkGauge
    INSTRUCTIONS = <<~TEXT.strip
      You are the river watch at Dosewallips State Park.
      Call river_staff once.
      Do not add a speech after the card.
    TEXT

    GAUGE_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, morning gauge at Dosewallips State Park.
      Park notes: https://parks.wa.gov/dosewallips
      Read the river staff for the incoming trail crew.
    TEXT

    Result = Struct.new(
      :read_after_generate,
      :read_after_tools,
      :settled,
      :chit,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      RiverStaff.reset!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(RiverStaff)
      chat.with_tool_options(choice: RiverStaff)

      chat.ask_later(GAUGE_QUESTION)
      chat.generate
      read_after_generate = RiverStaff.read?
      chat.run_tools

      Result.new(
        read_after_generate: read_after_generate,
        read_after_tools: RiverStaff.read?,
        settled: chat.complete?,
        chit: chat.messages.reverse.find { |message| message.role == :tool }&.content,
        roles: chat.messages.map(&:role)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "river_gauge") do
    result = DosewallipsGenerateRunTools::ParkGauge.conduct
  end

  puts result.chit
end
