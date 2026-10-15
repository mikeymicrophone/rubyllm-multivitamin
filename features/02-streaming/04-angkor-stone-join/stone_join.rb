# frozen_string_literal: true

# Streaming · 04 · Angkor stone-join steps
#
# Teaches:
# - Ordered steps stay in order when a chunk ends mid-sentence.
# - The message returned after streaming is the assistant turn.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AngkorStoneJoin
  # The conservator at Angkor Wat calls the stone-join inspection in the
  # order the card lists it: laterite core, sandstone facing, iron cramps,
  # lime mortar.
  class StoneJoin
    INSTRUCTIONS = <<~TEXT.strip
      You are the conservator on the west gallery at Angkor Wat.
      Call the four stone-join checks in the order given, one short sentence each.
      Use only the inspection card.
      Keep the four names in that order: laterite core, sandstone facing, iron cramps, lime mortar.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Stone-join inspection for Wednesday 14 October 2026, west gallery, Angkor Wat, Siem Reap.
      Conservation notes: https://whc.unesco.org/en/list/668/
      1. Laterite core is dry, both faces, and the joints are packed.
      2. Sandstone facing is sound, with no cracked course in the lower four.
      3. Iron cramps are fitted on the fifth course and sit square.
      4. Lime mortar runs the full length and the mason can bed it.
      Call the four checks in that order.
    TEXT

    Result = Struct.new(
      :speech,
      :pieces,
      :same_message,
      :role,
      :roles,
      :finish_reason,
      :stopped,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      pieces = []
      message = chat.ask(CARD_QUESTION) do |chunk|
        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      Result.new(
        speech: message.content,
        pieces: pieces,
        same_message: chat.messages.last.equal?(message),
        role: message.role,
        roles: chat.messages.map(&:role),
        finish_reason: message.finish_reason,
        stopped: message.stopped?
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "stone_join") do
    result = AngkorStoneJoin::StoneJoin.conduct
  end

  puts result.speech
end
