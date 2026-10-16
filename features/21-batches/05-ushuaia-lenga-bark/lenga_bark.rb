# frozen_string_literal: true

# Batches · 05 · Ushuaia lenga-bark embed_later
#
# Teaches:
# - RubyLLM.embed_later stages a text without contacting the provider.
# - RubyLLM.batch accepts embedding requests. results stay nil until complete.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module UshuaiaLengaBark
  class BarkBatch
    NORTH = "Ushuaia lenga yard, north stack, 14 bark bundles, clerk Malen."
    SOUTH = "Ushuaia lenga yard, south stack, 11 bark bundles, kettle at 09:05."

    Result = Struct.new(:batch_id, :status, :request_count, :results, :complete, keyword_init: true)

    def self.conduct
      configure
      requests = [
        RubyLLM.embed_later(NORTH, model: Multivitamin::Models::OPENAI_EMBEDDING, provider: :openai),
        RubyLLM.embed_later(SOUTH, model: Multivitamin::Models::OPENAI_EMBEDDING, provider: :openai)
      ]
      batch = RubyLLM.batch(requests)
      Result.new(
        batch_id: batch.id,
        status: batch.status,
        request_count: batch.requests.size,
        results: batch.results,
        complete: batch.complete?
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end

    def self.open_chat(model: nil)
      kwargs = Multivitamin::Models.chat(provider: :openai)
      kwargs = kwargs.merge(model: model) if model
      chat = RubyLLM.chat(**kwargs)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "lenga_bark") do
    result = UshuaiaLengaBark::BarkBatch.conduct
  end
  puts "id=#{result.batch_id} requests=#{result.request_count} complete=#{result.complete}"
end
