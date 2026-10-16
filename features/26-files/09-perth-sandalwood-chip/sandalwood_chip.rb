# frozen_string_literal: true

# Files · 09 · Perth sandalwood chip
#
# Teaches:
# - An IO needs filename: so the provider stores a useful name.
# - purpose: is still required on OpenAI.
# - The stored filename is sandalwood-chip.pdf, not a generated id.

require "logger"
require "stringio"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PerthSandalwoodChip
  class SandalwoodChip
    CARD = File.expand_path("sandalwood-chip.pdf", __dir__)

    Result = Struct.new(:file_id, :filename, :purpose, keyword_init: true)

    def self.conduct
      configure

      io = StringIO.new(File.binread(CARD))
      file = RubyLLM.upload(
        io,
        provider: :openai,
        purpose: "user_data",
        filename: "sandalwood-chip.pdf"
      )

      Result.new(
        file_id: file.id,
        filename: file.filename,
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
  Multivitamin::Cassettes.play(__dir__, "sandalwood_chip") do
    result = PerthSandalwoodChip::SandalwoodChip.conduct
  end

  puts "#{result.file_id} #{result.filename}"
end
