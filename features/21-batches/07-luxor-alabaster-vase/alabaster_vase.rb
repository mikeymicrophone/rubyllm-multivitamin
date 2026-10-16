# frozen_string_literal: true

# Batches · 07 · Luxor alabaster-vase cost until complete
#
# Teaches:
# - batch.cost.total is nil until the batch ends.
# - tokens stay empty while messages are still nil.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LuxorAlabasterVase
  class VaseBatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the vase clerk at the alabaster loft in Luxor.
      Answer in one short sentence from the card only.
      Name 7 vases and Nefret.
    TEXT

    CARD = <<~TEXT.strip
      Luxor alabaster loft card, Friday 16 October 2026.
      7 vases on the west bench. Nefret polishes the next rim.
      How many vases, and who polishes the rim?
    TEXT

    Result = Struct.new(:complete, :cost_total, :token_input, :status, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask_later(CARD)
      batch = RubyLLM.batch([chat])
      batch.refresh
      Result.new(
        complete: batch.complete?,
        cost_total: batch.cost.total,
        token_input: batch.tokens.input,
        status: batch.status
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
  Multivitamin::Cassettes.play(__dir__, "alabaster_vase") do
    result = LuxorAlabasterVase::VaseBatch.conduct
  end
  puts "complete=#{result.complete} cost=#{result.cost_total.inspect} tokens=#{result.token_input.inspect}"
end
