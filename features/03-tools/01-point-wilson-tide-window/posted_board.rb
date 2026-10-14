# frozen_string_literal: true

# Tools · 01 · Point Wilson tide window
#
# Teaches:
# - A RubyLLM::Tool subclass has a description and an execute method.
# - with_tools registers the class. RubyLLM 2.1.1 has no with_tool.
# - self.tool_name keeps a short name. A nested class would otherwise
#   keep the module, with :: written as --.
# - execute with no keywords returns a String. That string is the :tool
#   message, and the final answer is where the board shows up.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideWindow
  # The posted board is not in the question. The clerk has to read it
  # through the tool, then tell the watch when the tenders can leave.
  class PostedTideBoard < RubyLLM::Tool
    description "Reads the tide board posted at Point Wilson for the morning watch"

    def self.tool_name
      "posted_tide_board"
    end

    BOARD = <<~TEXT.strip
      Point Wilson tide board for Wednesday 14 October 2026.
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      Alden clears the kelp ledge at 10:46.
      Retort can use the float at 08:57.
    TEXT

    def execute
      BOARD
    end
  end

  class TideWindow
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Call posted_tide_board once. Then answer in two short sentences.
      Include the clock times the board gives for Alden and for Retort.
      Do not invent a tide height.
    TEXT

    WINDOW_QUESTION = <<~TEXT.strip
      Morning watch at Point Wilson, Wednesday 14 October 2026.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      The foghorn tender Alden and the cannery tender Retort are both at the float.
      When can each of them leave this morning?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(PostedTideBoard)
      chat.with_tool_options(choice: PostedTideBoard)

      answer = chat.ask(WINDOW_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "posted_board") do
    result = PointWilsonTideWindow::TideWindow.conduct
  end

  puts result.answer
end
