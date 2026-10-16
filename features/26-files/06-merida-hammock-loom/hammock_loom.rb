# frozen_string_literal: true

# Files · 06 · Mérida hammock loom
#
# Teaches:
# - auto_upload_large_files = false keeps attachments inline even if they
#   were large enough to upload.
# - A small hammock card is still file_data. There is no Files POST.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MeridaHammockLoom
  class HammockLoom
    CARD = File.expand_path("hammock-card.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the loom clerk in Mérida.
      Answer in one short sentence from the card only.
      Name Itzel and MER-2026-1016-H7.
    TEXT

    QUESTION = "Which hammock is on the card, and when does Itzel start? One sentence."

    Result = Struct.new(:brief, :auto_upload, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(QUESTION, with: CARD)

      Result.new(
        brief: brief.content,
        auto_upload: RubyLLM.config.auto_upload_large_files
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.auto_upload_large_files = false
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
  Multivitamin::Cassettes.play(__dir__, "hammock_loom") do
    result = MeridaHammockLoom::HammockLoom.conduct
  end

  puts "auto=#{result.auto_upload}"
  puts result.brief
end
