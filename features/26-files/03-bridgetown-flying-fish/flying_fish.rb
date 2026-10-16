# frozen_string_literal: true

# Files · 03 · Bridgetown flying fish
#
# Teaches:
# - expires_in: is seconds. OpenAI deletes the file after that window.
# - expires_at is a Time on the UploadedFile.
# - One day is 86_400 seconds.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BridgetownFlyingFish
  class FlyingFish
    CARD = File.expand_path("fish-card.pdf", __dir__)
    DAY = 24 * 60 * 60

    Result = Struct.new(:file_id, :expires_at, :purpose, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(CARD, provider: :openai, purpose: "user_data", expires_in: DAY)

      Result.new(
        file_id: file.id,
        expires_at: file.expires_at,
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
  Multivitamin::Cassettes.play(__dir__, "flying_fish") do
    result = BridgetownFlyingFish::FlyingFish.conduct
  end

  puts "#{result.file_id} expires=#{result.expires_at}"
end
