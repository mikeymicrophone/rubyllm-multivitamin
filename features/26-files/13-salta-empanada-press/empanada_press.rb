# frozen_string_literal: true

# Files · 13 · Salta empanada press
#
# Teaches:
# - Capstone: upload, find, ask, download.
# - The press card names Ines and SLA-2026-1016-E2.
# - Four HTTP calls: Files POST, GET metadata, Responses, GET content.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SaltaEmpanadaPress
  class EmpanadaPress
    CARD = File.expand_path("empanada-press.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the press clerk in Salta.
      Answer in one short sentence from the card only.
      Name Ines and SLA-2026-1016-E2.
    TEXT

    QUESTION = "Which lot is on the press card, and when does Ines fold? One sentence."

    Result = Struct.new(:file_id, :found_id, :brief, :blob, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(CARD, provider: :openai, purpose: "user_data")
      found = RubyLLM::UploadedFile.find(file.id, provider: :openai)
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(QUESTION, with: file)
      downloaded = RubyLLM.download(file.id, provider: :openai)

      Result.new(
        file_id: file.id,
        found_id: found.id,
        brief: brief.content,
        blob: downloaded.to_s
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "empanada_press") do
    result = SaltaEmpanadaPress::EmpanadaPress.conduct
  end

  puts result.file_id
  puts result.brief
end
