# frozen_string_literal: true

# Moderation · 10 · Arusha booking desk
#
# Teaches:
# - Screen the hail before chat.ask.
# - A clean booking card reaches gpt-4.1-mini.
# - The cassette is one Moderations POST and one Responses POST.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ArushaBookingDesk
  # The booking clerk in Arusha screens the morning hail, then asks the
  # chat only if it is clean. The lodge card names 07:15 and Asha.
  class BookingDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the booking clerk at a lodge desk in Arusha.
      Answer in one short sentence from the card only.
      Name Asha and 07:15.
    TEXT

    CARD = <<~TEXT.strip
      Booking card posted in Arusha, Friday 16 October 2026.
      Tanzania tourism: https://www.tanzaniatourism.go.tz/.
      Asha's party of four is due at 07:15 for the crater road. Lodge 2
      holds the breakfast trays. The crater road stays closed until dawn.
      When does Asha's party leave?
    TEXT

    Result = Struct.new(
      :flagged,
      :briefed,
      :brief,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      moderation = RubyLLM.moderate(CARD, **Multivitamin::Models.moderation)
      brief = nil
      roles = nil
      briefed = false
      unless moderation.flagged?
        chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
        chat.with_instructions(INSTRUCTIONS)
        chat.with_temperature(0.2)
        Multivitamin::Models.quiet_thinking(chat, provider: :openai)
        message = chat.ask(CARD)
        brief = message.content
        roles = chat.messages.map(&:role)
        briefed = true
      end

      Result.new(
        flagged: moderation.flagged?,
        briefed: briefed,
        brief: brief,
        roles: roles
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "booking_desk") do
    result = ArushaBookingDesk::BookingDesk.conduct
  end

  puts "flagged=#{result.flagged} briefed=#{result.briefed}"
  puts result.brief
end
