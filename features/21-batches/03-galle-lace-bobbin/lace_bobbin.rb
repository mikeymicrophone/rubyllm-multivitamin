# frozen_string_literal: true

# Batches · 03 · Galle lace-bobbin pending nil slots
#
# Teaches:
# - messages is an array the same length as the submitted chats.
# - A slot is nil while that request has no result yet.
# - Failed slots stay nil after the batch ends.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GalleLaceBobbin
  class BobbinBatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the bobbin clerk at the lace loft in Galle.
      Answer in one short sentence from the card only.
      Name 16 bobbins and Priyani.
    TEXT

    COUNT_CARD = <<~TEXT.strip
      Galle lace loft card, Friday 16 October 2026.
      16 bobbins on the south pillow. Priyani winds the next pair.
      How many bobbins sit on the pillow?
    TEXT

    WIND_CARD = <<~TEXT.strip
      Galle lace loft card, Friday 16 October 2026.
      Priyani winds the next pair at 08:25.
      Who winds the next pair?
    TEXT

    Result = Struct.new(:size, :slots, :complete, :status, keyword_init: true)

    def self.conduct
      configure
      chats = [
        open_chat.with_instructions(INSTRUCTIONS).with_temperature(0.2).ask_later(COUNT_CARD),
        open_chat.with_instructions(INSTRUCTIONS).with_temperature(0.2).ask_later(WIND_CARD)
      ]
      batch = RubyLLM.batch(chats)
      slots = batch.messages
      Result.new(size: slots.size, slots: slots, complete: batch.complete?, status: batch.status)
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
  Multivitamin::Cassettes.play(__dir__, "lace_bobbin") do
    result = GalleLaceBobbin::BobbinBatch.conduct
  end
  puts "size=#{result.size} complete=#{result.complete} nils=#{result.slots.count(&:nil?)}"
end
