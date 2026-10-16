# frozen_string_literal: true

# Files · 01 · Timbuktu salt ledger
#
# Teaches:
# - RubyLLM.upload stores a PDF with purpose: "user_data".
# - chat.ask(..., with: file) reuses the provider file id.
# - The cassette is a Files POST then a Responses POST.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TimbuktuSaltLedger
  class SaltLedger
    LEDGER = File.expand_path("salt-ledger.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the salt clerk in Timbuktu.
      Answer in one short sentence from the ledger only.
      Name Aisha and TMB-2026-1016-S3.
    TEXT

    QUESTION = "Which lot is on the ledger, and when does Aisha weigh? One sentence."

    Result = Struct.new(:file_id, :filename, :purpose, :brief, :roles, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(LEDGER, provider: :openai, purpose: "user_data")
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(QUESTION, with: file)

      Result.new(
        file_id: file.id,
        filename: file.filename,
        purpose: file.purpose,
        brief: brief.content,
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "salt_ledger") do
    result = TimbuktuSaltLedger::SaltLedger.conduct
  end

  puts "#{result.file_id} #{result.purpose}"
  puts result.brief
end
