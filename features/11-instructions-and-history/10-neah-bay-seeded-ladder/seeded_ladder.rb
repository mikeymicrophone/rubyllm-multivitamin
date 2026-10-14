# frozen_string_literal: true

# Instructions and history · 10 · Neah Bay seeded ladder card
#
# Teaches:
# - add_message seeds a prior user and assistant turn with no HTTP call.
# - The next ask sends those seeded turns on the wire.
# - A later user turn can correct a height the seed left behind.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBaySeededLadder
  # The relief at Neah Bay walks in with last watch's boarding-ladder
  # card already written. Those two turns are seeded, then Calder's
  # recount corrects the step count.
  class SeededLadder
    INSTRUCTIONS = <<~TEXT.strip
      You are the pilot-ladder clerk off Neah Bay.
      Answer in two short sentences.
      Use only the ladder card in this chat.
      When a later turn corrects a figure, the card uses the corrected figure.
      Do not invent a step count.
    TEXT

    SEEDED_USER = <<~TEXT.strip
      Last watch boarding-ladder card, Tuesday night 13 October 2026.
      Pilot station: https://www.psp.wa.gov/
      Ladder showing 8 steps. Freeboard 2.0 m.
      The inbound is the grain ship Columbia Range.
      Record the step count and the freeboard.
    TEXT

    SEEDED_ASSISTANT = "The ladder shows 8 steps and 2.0 m freeboard for Columbia Range."

    CORRECTION_QUESTION = <<~TEXT.strip
      Calder just counted the ladder at first light, Wednesday 14 October 2026.
      True count is 9 steps and 2.2 m freeboard.
      Correct the boarding card for Columbia Range.
    TEXT

    Result = Struct.new(
      :correction,
      :roles_before_ask,
      :roles,
      :seeded_assistant,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.add_message(role: :user, content: SEEDED_USER)
      chat.add_message(role: :assistant, content: SEEDED_ASSISTANT)
      roles_before_ask = chat.messages.map(&:role)
      chat.with_temperature(0.2)
      correction = chat.ask(CORRECTION_QUESTION)

      Result.new(
        correction: correction.content,
        roles_before_ask: roles_before_ask,
        roles: chat.messages.map(&:role),
        seeded_assistant: chat.messages[2].content
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "seeded_ladder") do
    result = NeahBaySeededLadder::SeededLadder.conduct
  end

  puts result.correction
end
