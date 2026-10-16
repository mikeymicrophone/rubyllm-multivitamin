# frozen_string_literal: true

# Files · 08 · Canberra mint blank
#
# Teaches:
# - expires_at is set when expires_in: is given. Gemini's 48h window is
#   not this API.
# - expired? is false while the window is still open.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CanberraMintBlank
  class MintBlank
    CARD = File.expand_path("mint-blank.pdf", __dir__)
    HOUR = 60 * 60

    Result = Struct.new(:file_id, :expires_at, :expired, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(CARD, provider: :openai, purpose: "user_data", expires_in: HOUR)

      Result.new(
        file_id: file.id,
        expires_at: file.expires_at,
        expired: file.expired?
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
  Multivitamin::Cassettes.play(__dir__, "mint_blank") do
    result = CanberraMintBlank::MintBlank.conduct
  end

  puts "#{result.file_id} expired=#{result.expired} at=#{result.expires_at}"
end
