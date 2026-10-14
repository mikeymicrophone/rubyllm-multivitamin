# frozen_string_literal: true

# Tools · 13 · Admiralty Inlet watch desk
#
# Teaches:
# - Several tools are registered and the model picks.
# - A second ask on the same chat sends the earlier tool result back.
# - halt and RubyLLM::Tool::Halt are gone in 2.1.1. generate, then
#   run_tools, and do not continue: the loop stops on the tool message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletWatchDesk
  class PostedTideBoard < RubyLLM::Tool
    description "Reads the Point Wilson tide board, including when Alden clears the kelp ledge"

    def self.tool_name
      "posted_tide_board"
    end

    def execute
      "Point Wilson tide board. Low water 07:05, 1.1 ft. Alden clears the kelp ledge at 10:12."
    end
  end

  class PostedHornCard < RubyLLM::Tool
    description "Reads whether the Admiralty Inlet horn is running and the blast length"

    def self.tool_name
      "posted_horn_card"
    end

    def execute
      "Admiralty Inlet horn is running. Blast 3 seconds, silent 27 seconds."
    end
  end

  class LensCabinetLatch < RubyLLM::Tool
    description "Reads whether the Point Wilson lens cabinet is shut"

    def self.tool_name
      "lens_cabinet_latch"
    end

    def execute
      "Lens cabinet latch: shut. Lamp burning. Do not open it on this watch."
    end
  end

  class ReliefHandoff < RubyLLM::Tool
    description "Writes the relief chit and ends the watch. Call this only when asked for the chit."

    def self.tool_name
      "relief_handoff"
    end

    def execute
      "Relief chit. Alden clears at 10:12. Horn blast 3 seconds. Cabinet stays shut."
    end
  end

  class WatchDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the watch clerk at Point Wilson on Admiralty Inlet.
      Call exactly one tool: the board that answers the question.
      Do not call the other boards.
      Answer in one sentence that includes the figure the tool returned.
    TEXT

    TIDE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning watch at Point Wilson.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      When does the foghorn tender Alden clear the kelp ledge?
    TEXT

    HORN_QUESTION = "The relief asks whether the horn is running, and what the blast is."

    HANDOFF_QUESTION = "Write the relief chit and stop. Do not add a speech."

    Result = Struct.new(
      :tide_answer,
      :horn_answer,
      :chit,
      :roles,
      :tool_contents,
      :settled,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)
      chat.with_tools(PostedTideBoard, PostedHornCard, LensCabinetLatch)

      chat.with_tool_options(choice: :required)
      tide = chat.ask(TIDE_QUESTION)

      chat.with_tool_options(choice: :required)
      horn = chat.ask(HORN_QUESTION)

      chat.with_tools(ReliefHandoff)
      chat.with_tool_options(choice: ReliefHandoff)
      chat.ask_later(HANDOFF_QUESTION)
      chat.generate
      chat.run_tools

      Result.new(
        tide_answer: tide.content,
        horn_answer: horn.content,
        chit: chat.messages.reverse.find { |message| message.role == :tool }&.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        settled: chat.complete?
      )
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
  Multivitamin::Cassettes.play(__dir__, "watch_desk") do
    result = AdmiraltyInletWatchDesk::WatchDesk.conduct
  end

  puts result.tide_answer
  puts
  puts result.horn_answer
  puts
  puts result.chit
end
