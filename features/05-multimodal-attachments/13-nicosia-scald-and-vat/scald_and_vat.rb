# frozen_string_literal: true

# Multimodal attachments · 13 · Nicosia scald and vat
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

module NicosiaScaldAndVat
  # The halloumi shop has the vat board and the scald procedure at the
  # same time. Eleni's first scald and the vat hold are one brief.
  class ScaldAndVat
    BOARD = File.expand_path("scald-board.png", __dir__)
    PROCEDURE = File.expand_path("scald-procedure.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the clerk at a Nicosia halloumi shop.
      The photograph is the vat board.
      The PDF is the scald procedure.
      Answer in two short sentences.
      Include Eleni, the clock time of the first scald, and the hold in minutes for vat 2.
      Do not invent a figure.
    TEXT

    BRIEF_QUESTION = <<~TEXT.strip
      Vat 2 is on the cook in the PDF.
      Eleni is waiting on the vat board.
      When does Eleni take the first scald, and how long does vat 2 hold?
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
  Multivitamin::Cassettes.play(__dir__, "scald_and_vat") do
    result = NicosiaScaldAndVat::ScaldAndVat.conduct
  end

  puts result.brief
end
