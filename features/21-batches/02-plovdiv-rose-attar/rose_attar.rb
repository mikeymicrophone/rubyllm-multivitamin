# frozen_string_literal: true

# Batches · 02 · Plovdiv rose-attar Batch.find
#
# Teaches:
# - Persist batch.id, then Batch.find(id, provider:) from another process.
# - The found batch carries the same id and a fresh status.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PlovdivRoseAttar
  class AttarBatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the attar clerk at the rose loft in Plovdiv.
      Answer in one short sentence from the card only.
      Name 22 flasks and Nevena.
    TEXT

    CARD = <<~TEXT.strip
      Plovdiv rose-attar card, Friday 16 October 2026.
      22 flasks on the north shelf. Nevena corks the next flask.
      How many flasks, and who corks the next one?
    TEXT

    Result = Struct.new(:submitted_id, :found_id, :found_status, :same_id, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask_later(CARD)
      submitted = RubyLLM.batch([chat])
      found = RubyLLM::Batch.find(submitted.id, provider: :openai)
      Result.new(
        submitted_id: submitted.id,
        found_id: found.id,
        found_status: found.status,
        same_id: submitted.id == found.id
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
  Multivitamin::Cassettes.play(__dir__, "rose_attar") do
    result = PlovdivRoseAttar::AttarBatch.conduct
  end
  puts "submitted=#{result.submitted_id} found=#{result.found_id} status=#{result.found_status}"
end
