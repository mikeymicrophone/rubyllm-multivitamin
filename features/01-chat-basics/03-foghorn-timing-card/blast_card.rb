# frozen_string_literal: true

# Chat basics · 03 · Foghorn timing card at Cape Disappointment
#
# Teaches:
# - with_temperature set very low, because a timing card must not be embellished.
# - with_instructions tells the horn tender to stay on the card.
# - A short reply is still a full RubyLLM::Message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentFoghorn
  # The horn tender copies the posted timing card onto the watch slate.
  # Extra sentences would put the wrong blast on the slate.
  class BlastCard
    INSTRUCTIONS = <<~TEXT.strip
      You are the foghorn tender at Cape Disappointment, in the horn house
      below North Head.
      Copy the timing card in three lines and then stop.
      Use only the card in the question.
      Do not describe the park, the lighthouse tour, or the Columbia River bar.
      Line 1 must be "Blast: 2 seconds".
      Line 2 must be "Silent: 18 seconds".
      Line 3 must be "Horn: diaphone".
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Timing card posted in the horn house at Cape Disappointment.
      The headland is Cape Disappointment State Park, https://parks.wa.gov/find-parks/state-parks/cape-disappointment-state-park.
      The card, not the park brochure, is what the tender copies:
      Blast 2 seconds.
      Silent 18 seconds.
      The horn is the diaphone, not the bell and not the siren.
      Characteristic repeats for as long as the watch keeps the horn running.
      Write the three-line slate.
    TEXT

    Result = Struct.new(
      :card,
      :temperature,
      :finish_reason,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.0)

      reply = chat.ask(CARD_QUESTION)

      Result.new(
        card: reply.content,
        temperature: chat.temperature,
        finish_reason: reply.finish_reason,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "blast_card") do
    result = CapeDisappointmentFoghorn::BlastCard.conduct
  end

  puts result.card
  puts
  puts "temperature=#{result.temperature.inspect} finish=#{result.finish_reason} chars=#{result.card.to_s.length}"
end
