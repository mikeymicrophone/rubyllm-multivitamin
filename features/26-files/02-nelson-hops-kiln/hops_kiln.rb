# frozen_string_literal: true

# Files · 02 · Nelson hops kiln
#
# Teaches:
# - purpose: "batch" is required for a jsonl mill sheet on OpenAI.
# - The upload does not start a batch. It only stores the file.
# - filename and mime_type come back on the UploadedFile.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NelsonHopsKiln
  class HopsKiln
    SHEET = File.expand_path("hops-batch.jsonl", __dir__)

    Result = Struct.new(:file_id, :filename, :purpose, :byte_size, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(SHEET, provider: :openai, purpose: "batch")

      Result.new(
        file_id: file.id,
        filename: file.filename,
        purpose: file.purpose,
        byte_size: file.byte_size
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
  Multivitamin::Cassettes.play(__dir__, "hops_kiln") do
    result = NelsonHopsKiln::HopsKiln.conduct
  end

  puts "#{result.file_id} #{result.purpose} #{result.filename} #{result.byte_size}"
end
