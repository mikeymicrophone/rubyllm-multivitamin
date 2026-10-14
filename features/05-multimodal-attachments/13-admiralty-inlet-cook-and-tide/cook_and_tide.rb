# frozen_string_literal: true

# Multimodal attachments · 13 · Admiralty Inlet cook and tide
#
# Teaches:
# - One ask can carry an image and a PDF.
# - gpt-4.1-mini accepts both, so the watch does not split the question
#   across two models.
# - The request has an input_image part and an input_file part.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletCookAndTide
  # The watch has the Point Wilson tide board and the Anacortes cook card
  # at the same time. Alden's departure and the retort hold are one brief.
  class CookAndTide
    BOARD = File.expand_path("tide-board.png", __dir__)
    PROCEDURE = File.expand_path("cook-procedure.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the watch clerk for Admiralty Inlet.
      The photograph is the Point Wilson tide board.
      The PDF is the Anacortes retort cook procedure.
      Answer in two short sentences.
      Include the clock time when Alden clears the kelp ledge, and the hold in minutes for basket 3.
      Do not invent a figure.
    TEXT

    BRIEF_QUESTION = <<~TEXT.strip
      The cannery tender Retort is on the cook in the PDF.
      The foghorn tender Alden is waiting on the tide board.
      When does Alden clear the kelp ledge, and how long does basket 3 hold?
    TEXT

    Result = Struct.new(:brief, :attachment_types, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      brief = chat.ask(BRIEF_QUESTION, with: [BOARD, PROCEDURE])
      user = chat.messages.find { |message| message.role == :user }

      Result.new(
        brief: brief.content,
        attachment_types: user.attachments.map(&:type),
        finish: brief.finish_reason,
        input_tokens: brief.tokens.input,
        cost: brief.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      chat.with_temperature(0)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.auto_upload_large_files = true
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
  Multivitamin::Cassettes.play(__dir__, "cook_and_tide") do
    result = AdmiraltyInletCookAndTide::CookAndTide.conduct
  end

  puts result.brief
end
