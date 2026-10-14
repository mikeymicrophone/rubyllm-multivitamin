# frozen_string_literal: true

# Chat basics · 06 · Pilot boarding ladder check off Neah Bay
#
# Teaches:
# - Two chats can ask the same question of two models.
# - Each chat names provider: :openrouter and assume_model_exists: true,
#   because the free slugs are not in the bundled registry.
# - with_model switches the model on a chat that already has turns,
#   and the earlier ladder question stays in the transcript.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayPilotLadder
  # The pilot boat Alden is off Neah Bay. The mate checks the rigged ladder
  # on one model, asks the spare-ladder follow-up after a model switch, and
  # asks the original question again on a fresh chat with the other model.
  class LadderCheck
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate on the pilot boat Alden, boarding ships off Neah Bay.
      Answer in two short sentences.
      Use only the ladder notes in the conversation.
      The first sentence starts with Yes or No.
      Do not invent ladder lengths.
    TEXT

    LADDER_QUESTION = <<~TEXT.strip
      Boarding the bulk carrier Silver Kelp off Neah Bay.
      The chart on the pilot's clipboard is from https://www.nauticalcharts.noaa.gov/.
      The light list the mate checked is https://www.navcen.uscg.gov/.
      Rigged ladder: 9 meters of side ropes, wooden steps, manropes on both sides.
      Embarkation deck: 8.4 meters above the water.
      The pilot boat's rail sits 1.5 meters above the water.
      The ladder has to reach from the deck down to that rail.
      Is the rigged 9 meter ladder long enough?
    TEXT

    SPARE_QUESTION = "The boatswain wants the spare 6 meter ladder instead of the rigged one. Does that spare reach the rail?"

    Result = Struct.new(
      :nemotron,
      :nemotron_model_id,
      :spare,
      :spare_model_id,
      :switched_chat_model_id,
      :liquid,
      :liquid_model_id,
      :switched_roles,
      :fresh_roles,
      :first_user_still_present,
      keyword_init: true
    )

    def self.conduct
      configure

      nemotron = open_chat(Multivitamin::Models::CHAT)
      nemotron.with_instructions(INSTRUCTIONS)
      nemotron.with_temperature(0.2)
      nemotron_reply = nemotron.ask(LADDER_QUESTION)

      nemotron.with_model(
        Multivitamin::Models::CHAT_FALLBACK,
        provider: :openrouter,
        assume_model_exists: true
      )
      spare_reply = nemotron.ask(SPARE_QUESTION)

      liquid = open_chat(Multivitamin::Models::CHAT_FALLBACK)
      liquid.with_instructions(INSTRUCTIONS)
      liquid.with_temperature(0.2)
      liquid_reply = liquid.ask(LADDER_QUESTION)

      Result.new(
        nemotron: nemotron_reply.content,
        nemotron_model_id: nemotron_reply.model,
        spare: spare_reply.content,
        spare_model_id: spare_reply.model,
        switched_chat_model_id: nemotron.model.id,
        liquid: liquid_reply.content,
        liquid_model_id: liquid_reply.model,
        switched_roles: nemotron.messages.map(&:role),
        fresh_roles: liquid.messages.map(&:role),
        first_user_still_present: nemotron.messages.any? { |message|
          message.role == :user && message.content.include?("9 meters")
        }
      )
    end

    def self.open_chat(model)
      RubyLLM.chat(
        model: model,
        provider: :openrouter,
        assume_model_exists: true
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
  Multivitamin::Cassettes.play(__dir__, "ladder_check") do
    result = NeahBayPilotLadder::LadderCheck.conduct
  end

  puts "nemotron (#{result.nemotron_model_id}):"
  puts result.nemotron
  puts
  puts "spare after with_model (#{result.spare_model_id}):"
  puts result.spare
  puts
  puts "fresh second model (#{result.liquid_model_id}):"
  puts result.liquid
end
