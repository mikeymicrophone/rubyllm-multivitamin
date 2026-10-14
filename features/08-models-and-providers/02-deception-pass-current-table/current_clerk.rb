# frozen_string_literal: true

# Models and providers · 02 · Deception Pass current-table clerk
#
# Teaches:
# - find returns a RubyLLM::Model for a known id.
# - supports?(:function_calling) is a capability check on that object.
# - price(:input) and context_window are metadata on the same object.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module DeceptionPassCurrentTable
  # The current-table clerk at Deception Pass looks up one model the way the
  # watch looks up a predicted slack in the whirlpool, then reads whether it
  # can call tools and what the window and price are.
  class CurrentClerk
    Result = Struct.new(
      :id,
      :name,
      :provider,
      :family,
      :type,
      :context_window,
      :max_output_tokens,
      :function_calling,
      :vision,
      :structured_output,
      :input_price,
      :output_price,
      keyword_init: true
    )

    def self.conduct
      configure

      model = RubyLLM.models.find("gpt-4.1-mini")

      Result.new(
        id: model.id,
        name: model.name,
        provider: model.provider,
        family: model.family,
        type: model.type,
        context_window: model.context_window,
        max_output_tokens: model.max_output_tokens,
        function_calling: model.supports?(:function_calling),
        vision: model.supports?(:vision),
        structured_output: model.supports?(:structured_output),
        input_price: model.price(:input),
        output_price: model.price(:output)
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
  Multivitamin::Cassettes.play(__dir__, "current_clerk") do
    result = DeceptionPassCurrentTable::CurrentClerk.conduct
  end

  puts "#{result.provider} #{result.id} window #{result.context_window}"
  puts "function_calling=#{result.function_calling} input=#{result.input_price}"
end
