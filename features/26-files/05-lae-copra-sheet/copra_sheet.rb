# frozen_string_literal: true

# Files · 05 · Lae copra sheet
#
# Teaches:
# - auto_upload_large_files is on by default.
# - OpenAI's inline limit is 50 MiB. A small copra sheet stays inline.
# - The cassette is one Responses POST. There is no Files POST.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LaeCopraSheet
  class CopraSheet
    SHEET = File.expand_path("copra-sheet.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the kiln clerk in Lae.
      Answer in one short sentence from the sheet only.
      Name Naomi and LAE-2026-1016-C4.
    TEXT

    QUESTION = "Which lot is on the copra sheet, and when does Naomi count? One sentence."

    Result = Struct.new(:brief, :byte_size, :auto_upload, keyword_init: true)

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      brief = chat.ask(QUESTION, with: SHEET)

      Result.new(
        brief: brief.content,
        byte_size: File.size(SHEET),
        auto_upload: RubyLLM.config.auto_upload_large_files
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.auto_upload_large_files = true
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
  Multivitamin::Cassettes.play(__dir__, "copra_sheet") do
    result = LaeCopraSheet::CopraSheet.conduct
  end

  puts "bytes=#{result.byte_size} auto=#{result.auto_upload}"
  puts result.brief
end
