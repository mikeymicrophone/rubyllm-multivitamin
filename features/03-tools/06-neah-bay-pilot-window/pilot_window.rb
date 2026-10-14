# frozen_string_literal: true

# Tools · 06 · Neah Bay pilot window
#
# Teaches:
# - with_tools(nil) clears the set. The next with_tools starts a new one.
# - The cleared tool is absent from the request. There is no with_tool
#   singular to swap with.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayPilotWindow
  class MakahTideWindow < RubyLLM::Tool
    description "Reads the Neah Bay tide window. Not the pilot ladder."

    def self.tool_name
      "makah_tide_window"
    end

    def execute
      "Neah Bay low water is 05:48."
    end
  end

  class PilotLadderWindow < RubyLLM::Tool
    description "Reads the boarding window for the pilot ladder off Neah Bay"

    def self.tool_name
      "pilot_ladder_window"
    end

    def execute
      "Neah Bay pilot ladder is open from 09:10 to 11:40. The ladder is on the starboard side. Swell is 4 ft."
    end
  end

  class LadderWindow
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate on the pilot ladder off Neah Bay.
      Call pilot_ladder_window. Answer in one sentence.
      Include the open times the tool returns.
    TEXT

    LADDER_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, pilot boarding off Neah Bay.
      Tide station: https://tidesandcurrents.noaa.gov/stationhome.html?id=9443090
      Chart: https://www.nauticalcharts.noaa.gov/
      When is the ladder open for the pilot, and which side is it on?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :registered, keyword_init: true)

    def self.conduct
      configure

      chat = open_desk
      chat.with_tool_options(choice: PilotLadderWindow)
      answer = chat.ask(LADDER_QUESTION)
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
      chat.with_thinking(false)
      chat.with_tools(MakahTideWindow)
      chat.with_tools(nil)
      chat.with_tools(PilotLadderWindow)
      chat
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "pilot_window") do
    result = NeahBayPilotWindow::LadderWindow.conduct
  end

  puts result.answer
end
