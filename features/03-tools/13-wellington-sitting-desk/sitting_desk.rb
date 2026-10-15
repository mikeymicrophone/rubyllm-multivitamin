# frozen_string_literal: true

# Tools · 13 · Wellington sitting desk
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

module WellingtonSittingDesk
  class PostedSittingBoard < RubyLLM::Tool
    description "Reads the Beehive sitting board, including when Aroha clears the public gallery"

    def self.tool_name
      "posted_sitting_board"
    end

    def execute
      "Beehive sitting board. First question 07:05. Aroha clears the public gallery at 10:12."
    end
  end

  class PostedBellCard < RubyLLM::Tool
    description "Reads whether the division bells are running and the ring length"

    def self.tool_name
      "posted_bell_card"
    end

    def execute
      "Division bells are running. Ring 3 seconds, silent 27 seconds."
    end
  end

  class GalleryLatch < RubyLLM::Tool
    description "Reads whether the Beehive press gallery is shut"

    def self.tool_name
      "gallery_latch"
    end

    def execute
      "Press gallery latch: shut. Lights burning. Do not open it on this sitting."
    end
  end

  class ReliefHandoff < RubyLLM::Tool
    description "Writes the relief chit and ends the sitting. Call this only when asked for the chit."

    def self.tool_name
      "relief_handoff"
    end

    def execute
      "Relief chit. Aroha clears at 10:12. Bell ring 3 seconds. Gallery stays shut."
    end
  end

  class SittingDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the sitting clerk at the Beehive in Wellington.
      Call exactly one tool: the board that answers the question.
      Do not call the other boards.
      Answer in one sentence that includes the figure the tool returned.
    TEXT

    SITTING_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, morning sitting at the Beehive.
      Order paper: https://www.parliament.nz/
      When does clerk Aroha clear the public gallery?
    TEXT

    BELL_QUESTION = "The relief asks whether the bells are running, and what the ring is."

    HANDOFF_QUESTION = "Write the relief chit and stop. Do not add a speech."

    Result = Struct.new(
      :sitting_answer,
      :bell_answer,
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
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(PostedSittingBoard, PostedBellCard, GalleryLatch)

      chat.with_tool_options(choice: :required)
      sitting = chat.ask(SITTING_QUESTION)

      chat.with_tool_options(choice: :required)
      bell = chat.ask(BELL_QUESTION)

      chat.with_tools(ReliefHandoff)
      chat.with_tool_options(choice: ReliefHandoff)
      chat.ask_later(HANDOFF_QUESTION)
      chat.generate
      chat.run_tools

      Result.new(
        sitting_answer: sitting.content,
        bell_answer: bell.content,
        chit: chat.messages.reverse.find { |message| message.role == :tool }&.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        settled: chat.complete?
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
  Multivitamin::Cassettes.play(__dir__, "sitting_desk") do
    result = WellingtonSittingDesk::SittingDesk.conduct
  end

  puts result.sitting_answer
  puts
  puts result.bell_answer
  puts
  puts result.chit
end
