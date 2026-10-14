# frozen_string_literal: true

# Multimodal attachments · 09 · Bremerton sill refusal
#
# Teaches:
# - A spreadsheet on Chat Completions raises UnsupportedAttachmentError
#   before any HTTP call.
# - The same protocol can format audio. gpt-4.1-mini still rejects that
#   part with HTTP 400.
# - convert_unsupported_attachments runs for the spreadsheet and does not
#   run for the API rejection. Returning nil keeps the original error.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonSillRefusal
  # The dry dock office has a workbook and a spoken sounding. Neither one
  # is a photograph, and the chat in use is gpt-4.1-mini on Chat Completions.
  class SillRefusal
    BOOK = File.expand_path("sill-book.xlsx", __dir__)
    SOUNDING = File.expand_path("sill-sounding.mp3", __dir__)

    BOOK_QUESTION = "Read the caisson sill depth and the clock time from the workbook."
    SOUNDING_QUESTION = "What sill depth does the sounding call?"

    Result = Struct.new(
      :workbook_error,
      :audio_error,
      :audio_status,
      :workbook_converter_calls,
      :audio_converter_calls,
      :workbook_mime,
      keyword_init: true
    )

    def self.conduct
      configure
      workbook = RubyLLM::Attachment.new(BOOK)
      workbook_error, workbook_calls = ask_workbook
      audio_error, audio_calls = ask_sounding

      Result.new(
        workbook_error: workbook_error,
        audio_error: audio_error,
        audio_status: audio_error&.response&.status,
        workbook_converter_calls: workbook_calls,
        audio_converter_calls: audio_calls,
        workbook_mime: workbook.mime_type
      )
    end

    def self.ask_workbook
      calls = 0
      chat = open_chat
      chat.convert_unsupported_attachments do |_attachment|
        calls += 1
        nil
      end
      chat.ask(BOOK_QUESTION, with: BOOK)
      [nil, calls]
    rescue RubyLLM::UnsupportedAttachmentError => error
      [error, calls]
    end

    def self.ask_sounding
      calls = 0
      chat = open_chat
      chat.convert_unsupported_attachments do |_attachment|
        calls += 1
        nil
      end
      chat.ask(SOUNDING_QUESTION, with: SOUNDING)
      [nil, calls]
    rescue RubyLLM::Error => error
      [error, calls]
    end

    def self.open_chat
      chat = RubyLLM.chat(
        model: Multivitamin::Models::OPENAI_CHAT,
        provider: :openai,
        protocol: :chat_completions
      )
      chat.with_temperature(0)
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
  Multivitamin::Cassettes.play(__dir__, "sill_refusal") do
    result = BremertonSillRefusal::SillRefusal.conduct
  end

  puts result.workbook_error
  puts result.audio_error
end
