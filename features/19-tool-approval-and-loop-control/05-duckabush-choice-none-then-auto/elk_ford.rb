# frozen_string_literal: true

# Tool approval and loop control · 05 · Duckabush choice :none then :auto
#
# Teaches:
# - choice: :none keeps the ford staff registered but out of the model's
#   hands. The first ask does not call it.
# - choice: :auto opens the tools again. The second ask reads the staff.
# - with_tools is not cleared. RubyLLM 2.1.1 has no with_params.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DuckabushChoiceNoneThenAuto
  class ElkFordDepth < RubyLLM::Tool
    description "Reads the posted depth at the Duckabush elk ford"

    def self.tool_name
      "elk_ford_depth"
    end

    CARD = <<~TEXT.strip
      Duckabush elk ford, Thursday 15 October 2026.
      Depth 2.4 ft on the gravel bar. The wapiti trail is holding.
    TEXT

    def execute
      CARD
    end
  end

  class FordWatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the trail watch at the Duckabush elk ford.
      When you may call tools, call elk_ford_depth once and answer in one
      short sentence that names the posted depth and the wapiti trail.
      When tools are closed, answer in one short sentence that you have
      not read the staff. Do not invent a depth.
    TEXT

    CLOSED_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, morning hail at the Duckabush elk ford.
      Trail notes: https://www.fs.usda.gov/olympic
      The incoming packer asks about the ford. Do not read the staff yet.
      What do you post?
    TEXT

    OPEN_QUESTION = <<~TEXT.strip
      Now read the elk ford staff and post the depth for the packer.
    TEXT

    Result = Struct.new(
      :closed_answer,
      :closed_roles,
      :open_answer,
      :tool_content,
      :roles,
      :tools_still_registered,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(ElkFordDepth)
      chat.with_tool_options(choice: :none)

      closed = chat.ask(CLOSED_QUESTION)
      closed_roles = chat.messages.map(&:role)

      chat.with_tool_options(choice: :auto)
      opened = chat.ask(OPEN_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        closed_answer: closed.content,
        closed_roles: closed_roles,
        open_answer: opened.content,
        tool_content: tool_message&.content,
        roles: chat.messages.map(&:role),
        tools_still_registered: chat.tools.keys.map(&:to_s)
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
  Multivitamin::Cassettes.play(__dir__, "elk_ford") do
    result = DuckabushChoiceNoneThenAuto::FordWatch.conduct
  end

  puts result.closed_answer
  puts
  puts result.open_answer
end
