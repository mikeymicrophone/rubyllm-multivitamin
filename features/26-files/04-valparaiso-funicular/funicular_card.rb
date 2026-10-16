# frozen_string_literal: true

# Files · 04 · Valparaíso funicular
#
# Teaches:
# - UploadedFile.find reloads metadata by provider file id.
# - OpenAI will not download purpose: "user_data". That is HTTP 400.
# - Persist provider alongside the id.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ValparaisoFunicular
  class FunicularCard
    CARD = File.expand_path("funicular-card.pdf", __dir__)

    Result = Struct.new(:file_id, :found_filename, :same_id, :purpose, :download_error, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(CARD, provider: :openai, purpose: "user_data")
      found = RubyLLM::UploadedFile.find(file.id, provider: :openai)
      download_error = nil
      begin
        RubyLLM.download(file.id, provider: :openai)
      rescue RubyLLM::Error => raised
        download_error = raised
      end

      Result.new(
        file_id: file.id,
        found_filename: found.filename,
        same_id: found.id == file.id,
        purpose: found.purpose,
        download_error: download_error
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
  Multivitamin::Cassettes.play(__dir__, "funicular_card") do
    result = ValparaisoFunicular::FunicularCard.conduct
  end

  puts "#{result.file_id} same=#{result.same_id}"
  puts result.download_error.class
  puts result.download_error.message
end
