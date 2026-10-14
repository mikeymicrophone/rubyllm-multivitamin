# frozen_string_literal: true

# Embeddings · 07 · Ediz Hook buoy service notes
#
# Teaches:
# - An empty string still embeds on OpenAI. tokens.input is 0 and cost is 0.
# - An empty array raises RubyLLM::BadRequestError before a vector exists.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EdizHookBuoyNotes
  # The buoy tender off Ediz Hook tries to file a blank service card, then
  # an empty stack of cards. The blank card is a vector. The empty stack
  # is a 400.
  class BuoyNotes
    Result = Struct.new(
      :blank_length,
      :blank_tokens,
      :blank_cost,
      :blank_all_zero,
      :stack_error,
      :stack_message,
      keyword_init: true
    )

    def self.conduct
      configure
      args = Multivitamin::Models.embed(provider: :openai)
      blank = RubyLLM.embed("", **args)

      stack_error = nil
      stack_message = nil
      begin
        RubyLLM.embed([], **args)
      rescue RubyLLM::BadRequestError => error
        stack_error = error.class.name
        stack_message = error.message
      end

      Result.new(
        blank_length: blank.vectors.length,
        blank_tokens: blank.tokens.input,
        blank_cost: blank.cost.total,
        blank_all_zero: blank.vectors.all? { |value| value == 0.0 },
        stack_error: stack_error,
        stack_message: stack_message
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "buoy_notes") do
    result = EdizHookBuoyNotes::BuoyNotes.conduct
  end

  puts "blank #{result.blank_length} tokens #{result.blank_tokens}"
  puts result.stack_message
end
