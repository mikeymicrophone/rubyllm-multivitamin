# frozen_string_literal: true

# Multimodal attachments · 05 · Magelang Borobudur sheet
#
# Teaches:
# - with: accepts an https URL the station already trusts.
# - The request forwards that URL. RubyLLM does not inline the bytes
#   when the URL's extension already names an image type.
# - A path from an untrusted caller is a different problem. This URL is
#   fixed in the scenario.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MagelangBorobudurSheet
  # The Magelang survey desk keeps one public photograph of Borobudur.
  # The URL is the one the desk posted. It is not a caller argument.
  class BorobudurSheet
    SHEET = "https://upload.wikimedia.org/wikipedia/commons/7/73/Borobudur_Temple.jpg"

    INSTRUCTIONS = <<~TEXT.strip
      You are the survey clerk at Magelang.
      Answer in one sentence from the photograph.
      Name the temple and the island shown.
    TEXT

    SHEET_QUESTION = <<~TEXT.strip
      The Magelang survey desk trusts this photograph for the Borobudur site sheet.
      Which temple is shown, and on which island?
    TEXT

    Result = Struct.new(:reading, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      reading = chat.ask(SHEET_QUESTION, with: SHEET)

      Result.new(
        reading: reading.content,
        finish: reading.finish_reason,
        input_tokens: reading.tokens.input,
        cost: reading.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "borobudur_sheet") do
    result = MagelangBorobudurSheet::BorobudurSheet.conduct
  end

  puts result.reading
end
