# frozen_string_literal: true

# Instructions and history · 11 · Busan sprocket mistake left in
#
# Teaches:
# - An earlier assistant mistake can stay in chat.messages on purpose.
# - The next request still carries that wrong interval.
# - The follow-up can still read the front interval off the card.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BusanSprocketMistake
  # Last watch at a Busan film lab posted the rear sprocket as 6 frames.
  # The card says 2.5. The clerk leaves that mistake on the transcript
  # and asks only for the front sprocket.
  class SprocketMistake
    INSTRUCTIONS = <<~TEXT.strip
      You are the sprocket clerk at a 35 mm lab in Haeundae, Busan.
      Answer in two short sentences.
      Use only the sprocket card in this chat.
      Do not invent a frame interval.
    TEXT

    SEEDED_USER = <<~TEXT.strip
      Sprocket card posted at the Haeundae lab, Busan, Wednesday 14 October 2026.
      Festival page: https://www.biff.kr/
      Front sprocket: 4 frames.
      Rear sprocket: 2.5 frames.
      Both are fixed white when lined up the inbound printer to the contact gate.
      What is the rear sprocket interval?
    TEXT

    SEEDED_ASSISTANT = "The rear sprocket at Haeundae flashes every 6 frames."

    FRONT_QUESTION = "What is the front sprocket interval on the card?"

    Result = Struct.new(
      :front,
      :roles,
      :mistake_still_present,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.add_message(role: :user, content: SEEDED_USER)
      chat.add_message(role: :assistant, content: SEEDED_ASSISTANT)
      chat.with_temperature(0.2)
      front = chat.ask(FRONT_QUESTION)

      Result.new(
        front: front.content,
        roles: chat.messages.map(&:role),
        mistake_still_present: chat.messages.any? { |message|
          message.role == :assistant && message.content.include?("6 frames")
        }
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
  Multivitamin::Cassettes.play(__dir__, "sprocket_mistake") do
    result = BusanSprocketMistake::SprocketMistake.conduct
  end

  puts result.front
end
