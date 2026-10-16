# frozen_string_literal: true

# Batches · 08 · Rabat zellige-tile cancel
#
# Teaches:
# - batch.cancel asks the provider to stop an unfinished batch.
# - raw_status shows cancelling or cancelled. Already-finished requests still return.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RabatZelligeTile
  class TileBatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the tile clerk at the zellige loft in Rabat.
      Answer in one short sentence from the card only.
      Name 40 tiles and Imane.
    TEXT

    CARD = <<~TEXT.strip
      Rabat zellige loft card, Friday 16 October 2026.
      40 tiles on the north bench. Imane cuts the next star.
      How many tiles, and who cuts the star?
    TEXT

    Result = Struct.new(:raw_status, :status, :cancelled, :succeeded, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask_later(CARD)
      batch = RubyLLM.batch([chat])
      batch.cancel
      Result.new(
        raw_status: batch.raw_status,
        status: batch.status,
        cancelled: batch.cancelled?,
        succeeded: batch.succeeded?
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
  Multivitamin::Cassettes.play(__dir__, "zellige_tile") do
    result = RabatZelligeTile::TileBatch.conduct
  end
  puts "raw=#{result.raw_status} status=#{result.status} cancelled=#{result.cancelled}"
end
