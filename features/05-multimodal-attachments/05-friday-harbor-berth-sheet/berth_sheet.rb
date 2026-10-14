# frozen_string_literal: true

# Multimodal attachments · 05 · Friday Harbor berth sheet
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

module FridayHarborBerthSheet
  # The berth desk keeps the Army Map Service sheet of Friday Harbor.
  # The URL is the one the harbormaster posted. It is not a caller argument.
  class BerthSheet
    SHEET = "https://upload.wikimedia.org/wikipedia/commons/8/84/Friday_Harbor_Washington.jpg"

    INSTRUCTIONS = <<~TEXT.strip
      You are the berth clerk at Friday Harbor.
      Answer in one sentence from the map image.
      Name the harbor and the county printed on the sheet.
    TEXT

    SHEET_QUESTION = <<~TEXT.strip
      The harbormaster trusts this map sheet for the Friday Harbor berth desk.
      What harbor is named on it, and which county?
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
  Multivitamin::Cassettes.play(__dir__, "berth_sheet") do
    result = FridayHarborBerthSheet::BerthSheet.conduct
  end

  puts result.reading
end
