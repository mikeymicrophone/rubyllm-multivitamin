# frozen_string_literal: true

# Tools · 08 · Petra tomb hygrometer
#
# Teaches:
# - An exception raised inside execute leaves ask. It is not turned into
#   a tool message and it is not sent back to the model.
# - The assistant turn that requested the tool is already on the chat.

require_relative "../../../support/runtime"

module PetraTombHygrometer
  # The glass is off the board. The tool refuses the reading.
  class TombGlassUnseated < StandardError
  end

  class TombHygrometer < RubyLLM::Tool
    description "Reads the tomb hygrometer at a Petra monument"

    def self.tool_name
      "tomb_hygrometer"
    end

    parameter :tomb, type: :string, description: "Tomb whose glass to read", required: true

    def execute(tomb:)
      raise TombGlassUnseated, "The hygrometer glass at #{tomb} is off the board"
    end
  end

  class GlassCheck
    INSTRUCTIONS = <<~TEXT.strip
      You are the conservation watch for Petra.
      Call tomb_hygrometer for the tomb in the question.
    TEXT

    GLASS_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026 conservation round.
      Compare the glass later with https://whc.unesco.org/en/list/326/.
      Read the hygrometer at the Treasury.
    TEXT

    Result = Struct.new(:error, :roles, :tool_called, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(TombHygrometer)
      chat.with_tool_options(choice: TombHygrometer)

      error = nil
      begin
        chat.ask(GLASS_QUESTION)
      rescue TombGlassUnseated => raised
        error = raised
      end

      Result.new(
        error: error,
        roles: chat.messages.map(&:role),
        tool_called: chat.messages.any?(&:tool_call?)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "tomb_glass") do
    PetraTombHygrometer::GlassCheck.conduct
  end

  puts result.error.class
  puts result.error.message
end
