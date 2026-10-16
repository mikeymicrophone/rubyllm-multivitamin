# frozen_string_literal: true

# Tools · 06 · Tromsø aurora shutter window
#
# Teaches:
# - with_tools(nil) clears the set. The next with_tools starts a new one.
# - The cleared tool is absent from the request. There is no with_tool
#   singular to swap with.

require_relative "../../../support/runtime"

module TromsoAuroraShutter
  class KpIndexWindow < RubyLLM::Tool
    description "Reads the Tromsø Kp-index window. Not the camera shutter."

    def self.tool_name
      "kp_index_window"
    end

    def execute
      "Tromsø Kp floor is 05:48."
    end
  end

  class ShutterWindow < RubyLLM::Tool
    description "Reads the open shutter window for the aurora camera on Kvaløya"

    def self.tool_name
      "shutter_window"
    end

    def execute
      "Tromsø aurora shutter is open from 09:10 to 11:40. The camera faces the fjord. Cloud is 4 oktas."
    end
  end

  class CameraWindow
    INSTRUCTIONS = <<~TEXT.strip
      You are the night photographer on Kvaløya outside Tromsø.
      Call shutter_window. Answer in one sentence.
      Include the open times the tool returns.
    TEXT

    SHUTTER_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, aurora watch on Kvaløya.
      Forecast: https://www.yr.no/
      When is the shutter open for the exposure, and which way does the camera face?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :registered, keyword_init: true)

    def self.conduct
      configure

      chat = open_desk
      chat.with_tool_options(choice: ShutterWindow)
      answer = chat.ask(SHUTTER_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        registered: chat.tools.keys
      )
    end

    def self.open_desk
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(KpIndexWindow)
      chat.with_tools(nil)
      chat.with_tools(ShutterWindow)
      chat
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "shutter_window") do
    TromsoAuroraShutter::CameraWindow.conduct
  end

  puts result.answer
end
