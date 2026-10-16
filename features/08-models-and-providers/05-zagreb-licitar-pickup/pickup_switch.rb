# frozen_string_literal: true

# Models and providers · 05 · Zagreb licitar pickup switch
#
# Teaches:
# - with_model switches the model on a chat that already has turns.
# - The earlier pickup card stays in the transcript.
# - The second request names the new model id.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ZagrebLicitar
  # The counter at a Zagreb licitar workshop asks whether the posted
  # school pickup covers Ivana's class order, then switches models
  # before answering Grandmother Ana's coffee.
  class PickupSwitch
    INSTRUCTIONS = <<~TEXT.strip
      You are the counter clerk at a licitar workshop in Zagreb.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the pickup card in this chat.
      Do not invent times.
    TEXT

    PICKUP_QUESTION = <<~TEXT.strip
      Zagreb licitar pickup card, Wednesday 14 October 2026.
      Workshop page: https://www.licitar.hr/
      City page: https://www.zagreb.hr/
      Posted school pickup 10:15 to 10:30 for Ivana's class, forty red hearts for the school fair.
      Walk-in counter closed 10:00 to 10:40 so that box can be handed over.
      The class needs the box from 10:15 to 10:30.
      Does the posted pickup cover Ivana's 10:15 to 10:30 window?
    TEXT

    COFFEE_QUESTION = "Grandmother Ana has to be at the Dolac stall by 10:35 for her mid-morning coffee. If she waits at the walk-in counter, does she still sit through the 10:40 reopen?"

    Result = Struct.new(
      :opening,
      :opening_model,
      :bus,
      :bus_model,
      :chat_model_id,
      :roles,
      :first_user_still_present,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      opening = chat.ask(PICKUP_QUESTION)

      relief = relief_model
      chat.with_model(
        relief.fetch(:model),
        provider: relief.fetch(:provider),
        assume_model_exists: relief[:assume_model_exists] || false
      )
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      bus = chat.ask(COFFEE_QUESTION)

      Result.new(
        opening: opening.content,
        opening_model: opening.model,
        bus: bus.content,
        bus_model: bus.model,
        chat_model_id: chat.model.id,
        roles: chat.messages.map(&:role),
        first_user_still_present: chat.messages.any? { |message|
          message.role == :user && message.content.include?("Ivana")
        }
      )
    end

    def self.relief_model
      case Multivitamin::Models.recording_provider(:openai)
      when :openrouter
        { model: Multivitamin::Models::CHAT_FALLBACK, provider: :openrouter, assume_model_exists: true }
      else
        { model: Multivitamin::Models::OPENAI_CHAT_SWITCH, provider: :openai }
      end
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "pickup_switch") do
    result = ZagrebLicitar::PickupSwitch.conduct
  end

  puts "#{result.opening_model}: #{result.opening}"
  puts
  puts "#{result.bus_model}: #{result.bus}"
end
