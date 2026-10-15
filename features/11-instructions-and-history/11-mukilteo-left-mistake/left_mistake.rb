# frozen_string_literal: true

# Instructions and history · 11 · Mukilteo range-light mistake left in
#
# Teaches:
# - An earlier assistant mistake can stay in chat.messages on purpose.
# - The next request still carries that wrong flash.
# - The follow-up can still read the front interval off the card.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MukilteoLeftMistake
  # Last watch at Mukilteo posted the rear range as 6 seconds. The card
  # says 2.5. The clerk leaves that mistake on the transcript and asks
  # only for the front light.
  class LeftMistake
    INSTRUCTIONS = <<~TEXT.strip
      You are the range-light keeper at Mukilteo Light.
      Answer in two short sentences.
      Use only the flash card in this chat.
      Do not invent a flash interval.
    TEXT

    SEEDED_USER = <<~TEXT.strip
      Flash card posted at Mukilteo Light, Wednesday 14 October 2026.
      Light list: https://www.navcen.uscg.gov/
      Front range: 4 seconds.
      Rear range: 2.5 seconds.
      Both are fixed white when lined up the inbound course to Possession Sound.
      What is the rear range interval?
    TEXT

    SEEDED_ASSISTANT = "The rear range at Mukilteo flashes every 6 seconds."

    FRONT_QUESTION = "What is the front range interval on the card?"

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
          message.role == :assistant && message.content.include?("6 seconds")
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
  Multivitamin::Cassettes.play(__dir__, "left_mistake") do
    result = MukilteoLeftMistake::LeftMistake.conduct
  end

  puts result.front
end
