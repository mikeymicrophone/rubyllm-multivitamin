# frozen_string_literal: true

# Models and providers · 09 · Nairobi ticket-radio preference
#
# Teaches:
# - A bare id that exists on two providers resolves to the first-party one.
# - provider: pins the other copy.
# - provider: :openrouter resolves the same alias to the aggregator id.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module NairobiTicket
  # The desk at a Nairobi help-ticket radio names a clerk without saying
  # which channel, then names Azure when the watch wants that copy of the
  # same id.
  class TicketPreference
    Result = Struct.new(
      :bare_id,
      :bare_provider,
      :openai_id,
      :openai_provider,
      :azure_id,
      :azure_provider,
      :openrouter_id,
      :openrouter_provider,
      :carriers,
      keyword_init: true
    )

    def self.conduct
      configure

      bare = RubyLLM.models.find("gpt-4.1-mini")
      openai = RubyLLM.models.find("gpt-4.1-mini", provider: :openai)
      azure = RubyLLM.models.find("gpt-4.1-mini", provider: :azure)

      openrouter = RubyLLM.models.find("gpt-4.1-mini", provider: :openrouter)
      carriers = RubyLLM.models.all.select { |model| model.id == "gpt-4.1-mini" }.map(&:provider)

      Result.new(
        bare_id: bare.id,
        bare_provider: bare.provider,
        openai_id: openai.id,
        openai_provider: openai.provider,
        azure_id: azure.id,
        azure_provider: azure.provider,
        openrouter_id: openrouter.id,
        openrouter_provider: openrouter.provider,
        carriers: carriers
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "ticket_preference") do
    result = NairobiTicket::TicketPreference.conduct
  end

  puts "bare #{result.bare_provider} #{result.bare_id}"
  puts "azure #{result.azure_provider} #{result.azure_id}"
  puts "openrouter #{result.openrouter_provider} #{result.openrouter_id}"
  puts "carriers #{result.carriers.join(', ')}"
end
