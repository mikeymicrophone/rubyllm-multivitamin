# frozen_string_literal: true

# Instructions and history · 10 · Trondheim seeded bellows card
#
# Teaches:
# - add_message seeds a prior user and assistant turn with no HTTP call.
# - The next ask sends those seeded turns on the wire.
# - A later user turn can correct a count the seed left behind.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TrondheimBellowsSeed
  # The relief at Nidaros walks in with last watch's organ-bellows card
  # already written. Those two turns are seeded, then Sigrid's recount
  # corrects the fold count.
  class SeededBellows
    INSTRUCTIONS = <<~TEXT.strip
      You are the bellows clerk at Nidaros Cathedral in Trondheim.
      Answer in two short sentences.
      Use only the bellows card in this chat.
      When a later turn corrects a figure, the card uses the corrected figure.
      Do not invent a fold count.
    TEXT

    SEEDED_USER = <<~TEXT.strip
      Last watch organ-bellows card, Tuesday night 13 October 2026.
      Cathedral page: https://www.nidarosdomen.no/
      Bellows showing 8 folds. Wind 2.0 kPa.
      The inbound is the Steinmeyer loft for the morning chorale.
      Record the fold count and the wind.
    TEXT

    SEEDED_ASSISTANT = "The bellows show 8 folds and 2.0 kPa wind for the Steinmeyer loft."

    CORRECTION_QUESTION = <<~TEXT.strip
      Sigrid just counted the bellows at first light, Wednesday 14 October 2026.
      True count is 9 folds and 2.2 kPa wind.
      Correct the bellows card for the Steinmeyer loft.
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
  Multivitamin::Cassettes.play(__dir__, "seeded_bellows") do
    result = TrondheimBellowsSeed::SeededBellows.conduct
  end

  puts result.correction
end
