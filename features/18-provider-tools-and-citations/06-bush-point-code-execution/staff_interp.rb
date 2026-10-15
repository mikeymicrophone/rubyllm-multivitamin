# frozen_string_literal: true

# Provider tools and citations · 06 · Bush Point code execution
#
# Teaches:
# - with_provider_tools(:code_execution) sends type code_interpreter.
# - server_tool_calls records a code_interpreter_call.
# - tokens.server_tool_use stays nil on this model even after the run.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BushPointCodeExecution
  # The staff at Bush Point, on the west shore of Whidbey, needs the
  # interpolated kelp-ledge height at 10:46 before Alden leaves.
  class StaffInterp
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Bush Point.
      Use code execution. Answer in two short sentences.
      Name Bush Point and the tender Alden.
      Include the exact interpolated height.
      Do not invent a different formula.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Bush Point kelp ledge.
      Minutes from midnight: 06:42 is 402, 12:18 is 738, 10:46 is 646.
      Posted heights: 0.4 ft at 06:42, 8.1 ft at 12:18.
      Use code execution to compute 0.4 + (8.1 - 0.4) * (646 - 402) / (738 - 402).
      Print the exact number. Does Alden have 6.0 ft at 10:46?
    TEXT

    Result = Struct.new(
      :brief,
      :call_types,
      :server_tool_use,
      :roles,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(:code_execution)
      brief = chat.ask(QUESTION)

      Result.new(
        brief: brief.content,
        call_types: brief.server_tool_calls.map(&:type),
        server_tool_use: brief.tokens.server_tool_use,
        roles: chat.messages.map(&:role),
        cost: brief.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "staff_interp") do
    result = BushPointCodeExecution::StaffInterp.conduct
  end

  puts result.brief
end
