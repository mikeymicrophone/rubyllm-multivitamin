# frozen_string_literal: true

# Error handling · 07 · Partridge Bank logbook
#
# Teaches:
# - A pasted logbook that exceeds the embedding window is
#   ContextLengthExceededError, even on HTTP 400.
# - The class is not retried. max_retries 0 keeps the cassette to one
#   POST.
# - request_shape is nil: embeddings send no conversation.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PartridgeBankLogbook
  # The chart desk pastes a season of Partridge Bank soundings into one
  # embedding. text-embedding-3-small will not take more than 8192
  # tokens. The overflow is an error, not a truncated vector.
  class LogbookOverflow
    LEADS = %w[tallow sand shell gravel].freeze

    INSTRUCTIONS_NOTE = <<~TEXT.strip
      Partridge Bank sounding log, Admiralty Inlet, season 2026.
      Chart catalog: https://www.nauticalcharts.noaa.gov/.
    TEXT

    Result = Struct.new(
      :error,
      :status,
      :message,
      :shape,
      :is_llm_error,
      :retried,
      keyword_init: true
    )

    def self.conduct
      configure

      error = nil
      begin
        RubyLLM.embed(
          logbook,
          model: Multivitamin::Models::OPENAI_EMBEDDING,
          provider: :openai
        )
      rescue RubyLLM::Error => raised
        error = raised
      end

      Result.new(
        error: error,
        status: error&.response&.status,
        message: error&.message,
        shape: error&.request_shape,
        is_llm_error: error.is_a?(RubyLLM::Error),
        retried: false
      )
    end

    def self.logbook
      lines = [INSTRUCTIONS_NOTE]
      700.times do |index|
        depth = format("%.1f", 6.0 - ((index % 20) * 0.1))
        lines << "Cast #{index + 1} off Partridge Bank: #{depth} fathoms, " \
                 "ebb #{index % 3} knots, lead #{LEADS[index % 4]}."
      end
      lines.join("\n")
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
  Multivitamin::Cassettes.play(__dir__, "logbook_overflow") do
    result = PartridgeBankLogbook::LogbookOverflow.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.message
end
