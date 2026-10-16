# frozen_string_literal: true

# Files · 12 · Medan durian lot
#
# Teaches:
# - A CSV mill sheet uploads as user_data and downloads as the same rows.
# - Mistral-generated CSV needs a key this catalog does not have.
# - The round-trip keeps MDN-2026-1016-D9.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MedanDurianLot
  class DurianLot
    SHEET = File.expand_path("durian-lot.csv", __dir__)

    Result = Struct.new(:file_id, :filename, :blob, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(SHEET, provider: :openai, purpose: "user_data")
      downloaded = RubyLLM.download(file.id, provider: :openai)

      Result.new(
        file_id: file.id,
        filename: file.filename,
        blob: downloaded.to_s
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "durian_lot") do
    result = MedanDurianLot::DurianLot.conduct
  end

  puts "#{result.file_id} #{result.filename}"
  puts result.blob
end
