# frozen_string_literal: true

# Files · 11 · Ghent bobbin lace
#
# Teaches:
# - purpose: "batch" jsonl is downloadable on OpenAI. user_data is not.
# - DownloadedFile is a String. to_blob is the same bytes.
# - The mill copy survives the round-trip.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GhentBobbinLace
  class BobbinLace
    LOT = File.expand_path("lace-lot.jsonl", __dir__)

    Result = Struct.new(:file_id, :blob, :byte_size, :purpose, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(LOT, provider: :openai, purpose: "batch")
      downloaded = RubyLLM.download(file.id, provider: :openai)

      Result.new(
        file_id: file.id,
        blob: downloaded.to_blob,
        byte_size: downloaded.bytesize,
        purpose: file.purpose
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
  Multivitamin::Cassettes.play(__dir__, "bobbin_lace") do
    result = GhentBobbinLace::BobbinLace.conduct
  end

  puts "#{result.file_id} #{result.purpose} bytes=#{result.byte_size}"
  puts result.blob.include?("GNT-2026-1016-L6")
end
