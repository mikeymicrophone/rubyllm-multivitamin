# frozen_string_literal: true

# Batches · 01 · Asmara berbere-mill staged briefs
#
# Teaches:
# - ask_later stages a chat without contacting the provider.
# - RubyLLM.batch submits the staged chats and returns a Batch with an id.
# - status is :pending until the provider finishes.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AsmaraBerbereMill
  class MillBatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the mill clerk at the berbere loft in Asmara.
      Answer in one short sentence from the card only.
      Name 48 sacks and Yonas.
    TEXT

    SACK_QUESTION = <<~TEXT.strip
      Asmara berbere mill card, Friday 16 October 2026.
      48 sacks on the west floor. Yonas opens the next millstone.
      How many sacks, and who opens the stone?
    TEXT

    STONE_QUESTION = <<~TEXT.strip
      Asmara berbere mill card, Friday 16 October 2026.
      The north stone starts at 07:40. Yonas holds the hopper.
      When does the north stone start?
    TEXT

    Result = Struct.new(:batch_id, :status, :complete, :chat_count, keyword_init: true)

    def self.conduct
      configure
      chats = [
        open_chat.with_instructions(INSTRUCTIONS).with_temperature(0.2).ask_later(SACK_QUESTION),
        open_chat.with_instructions(INSTRUCTIONS).with_temperature(0.2).ask_later(STONE_QUESTION)
      ]
      batch = RubyLLM.batch(chats)
      Result.new(
        batch_id: batch.id,
        status: batch.status,
        complete: batch.complete?,
        chat_count: batch.chats.size
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
  Multivitamin::Cassettes.play(__dir__, "berbere_mill") do
    result = AsmaraBerbereMill::MillBatch.conduct
  end
  puts "id=#{result.batch_id} status=#{result.status} complete=#{result.complete} chats=#{result.chat_count}"
end
