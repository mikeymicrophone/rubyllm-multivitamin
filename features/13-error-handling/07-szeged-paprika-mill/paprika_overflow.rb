# frozen_string_literal: true

# Error handling · 07 · Szeged paprika mill
#
# Teaches:
# - A pasted dryer log that exceeds the embedding window is
#   ContextLengthExceededError, even on HTTP 400.
# - The class is not retried. max_retries 0 keeps the cassette to one
#   POST.
# - request_shape is nil: embeddings send no conversation.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SzegedPaprikaMill
  # The mill clerk pastes a season of Szeged paprika dryer readings into
  # one embedding. text-embedding-3-small will not take more than 8192
  # tokens. The overflow is an error, not a truncated vector.
  class PaprikaOverflow
    LEADS = %w[kalocsa csemege eros nemes].freeze

    INSTRUCTIONS_NOTE = <<~TEXT.strip
      Szeged paprika dryer log, Tisza mill, season 2026.
      City notes: https://www.szegedvaros.hu/.
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
        heat = format("%.1f", 62.0 - ((index % 20) * 0.1))
        lines << "Pass #{index + 1} at the Szeged mill: #{heat} C, " \
                 "humidity #{index % 3} percent, grade #{LEADS[index % 4]}."
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
  Multivitamin::Cassettes.play(__dir__, "paprika_overflow") do
    result = SzegedPaprikaMill::PaprikaOverflow.conduct
  end

  puts "#{result.error.class} #{result.status}"
  puts result.message
end
