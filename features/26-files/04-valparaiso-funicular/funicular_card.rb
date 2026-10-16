# frozen_string_literal: true

# Files · 04 · Valparaíso funicular
#
# Teaches:
# - UploadedFile.find reloads metadata by provider file id.
# - RubyLLM.download returns a DownloadedFile. save writes the bytes.
# - Persist provider alongside the id.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ValparaisoFunicular
  class FunicularCard
    CARD = File.expand_path("funicular-card.pdf", __dir__)

    Result = Struct.new(:file_id, :found_filename, :same_id, :blob, :saved_path, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(CARD, provider: :openai, purpose: "user_data")
      found = RubyLLM::UploadedFile.find(file.id, provider: :openai)
      downloaded = RubyLLM.download(file.id, provider: :openai)
      path = File.expand_path("tmp-funicular.pdf", __dir__)
      downloaded.save(path)
      blob = File.binread(path)
      File.delete(path) if File.exist?(path)

      Result.new(
        file_id: file.id,
        found_filename: found.filename,
        same_id: found.id == file.id,
        blob: blob,
        saved_path: path
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

  puts "#{result.file_id} same=#{result.same_id} bytes=#{result.blob.bytesize}"
end
