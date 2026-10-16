# frozen_string_literal: true

# Files · 11 · Ghent bobbin lace
#
# Teaches:
# - Downloaded bytes of a user_data PDF still contain the mill copy.
# - DownloadedFile is a String. Include the lot code directly.
# - DeepSeek image-download refusal needs a key this catalog does not have.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GhentBobbinLace
  class BobbinLace
    CARD = File.expand_path("lace-card.pdf", __dir__)

    Result = Struct.new(:file_id, :blob, :byte_size, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(CARD, provider: :openai, purpose: "user_data")
      downloaded = RubyLLM.download(file.id, provider: :openai)

      Result.new(
        file_id: file.id,
        blob: downloaded.to_blob,
        byte_size: downloaded.bytesize
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

  puts "#{result.file_id} bytes=#{result.byte_size}"
  puts result.blob.include?("GNT-2026-1016-L6")
end
