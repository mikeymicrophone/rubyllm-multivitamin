# frozen_string_literal: true

# Multimodal attachments · 12 · Tashkent cadastral margin
#
# Teaches:
# - A scan with no extension is still an image when the bytes are a PNG.
# - RubyLLM sniffs the MIME type from the bytes. The caller does not pass one.
# - The request sends image/png, and the reply names the correction in the margin.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TashkentCadastralMargin
  # The plotter saved the margin scan without an extension. The clerk
  # still hands that path to ask.
  class CadastralMargin
    SCAN = File.expand_path("cadastral-margin", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the cadastre clerk in Tashkent.
      Answer in one sentence from the scan only.
      Name the plot number, the marker, and the area in the margin correction.
      Do not invent a figure.
    TEXT

    CORRECTION_QUESTION = <<~TEXT.strip
      The plotter dropped the filename extension on this margin scan.
      What plot is it, which marker moved, and how far?
    TEXT

    Result = Struct.new(:notice, :mime_type, :extension, :attachment_type, :finish, :cost, keyword_init: true)

    def self.conduct
      configure
      scan = RubyLLM::Attachment.new(SCAN)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      notice = chat.ask(CORRECTION_QUESTION, with: scan)

      Result.new(
        notice: notice.content,
        mime_type: scan.mime_type,
        extension: scan.extension,
        attachment_type: scan.type,
        finish: notice.finish_reason,
        cost: notice.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "cadastral_margin") do
    result = TashkentCadastralMargin::CadastralMargin.conduct
  end

  puts result.notice
end
