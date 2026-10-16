# frozen_string_literal: true

# Batches · 12 · Split limestone-block headers dropped
#
# Teaches:
# - with_headers stays on the Chat object.
# - chat.render, which the batch uploads, does not include those headers.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SplitLimestoneBlock
  class BlockBatch
    SHIFT_HEADER = "X-Workshop-Shift"
    SHIFT_VALUE = "dawn-cut"

    INSTRUCTIONS = <<~TEXT.strip
      You are the block clerk at the limestone yard in Split.
      Answer in one short sentence from the card only.
      Name 6 blocks and Ante.
    TEXT

    CARD = <<~TEXT.strip
      Split limestone yard card, Friday 16 October 2026.
      6 blocks on the south face. Ante marks the next cut.
      How many blocks, and who marks the cut?
    TEXT

    Result = Struct.new(:batch_id, :headers, :payload_keys, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_headers(SHIFT_HEADER => SHIFT_VALUE)
      chat.ask_later(CARD)
      payload = chat.render
      batch = RubyLLM.batch([chat])
      Result.new(batch_id: batch.id, headers: chat.headers, payload_keys: payload.keys.map(&:to_s))
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
  Multivitamin::Cassettes.play(__dir__, "limestone_block") do
    result = SplitLimestoneBlock::BlockBatch.conduct
  end
  puts "id=#{result.batch_id} headers=#{result.headers.inspect} keys=#{result.payload_keys.join(",")}"
end
