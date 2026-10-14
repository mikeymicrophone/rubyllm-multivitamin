# frozen_string_literal: true

# Models and providers · 05 · Hood Canal Bridge opening switch
#
# Teaches:
# - with_model switches the model on a chat that already has turns.
# - The earlier opening card stays in the transcript.
# - The second request names the new model id.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HoodCanalBridge
  # The tender on the Hood Canal Bridge (WA-104) asks whether the
  # scheduled opening clears the tug Salish Pontoon, then switches models
  # before answering the Poulsbo school bus.
  class OpeningSwitch
    INSTRUCTIONS = <<~TEXT.strip
      You are the bridge tender on the Hood Canal Bridge, WA-104.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the opening card in this chat.
      Do not invent times.
    TEXT

    OPENING_QUESTION = <<~TEXT.strip
      Hood Canal Bridge opening card, Wednesday 14 October 2026.
      WSDOT page: https://wsdot.wa.gov/travel/washington-state-ferries
      Bridge page: https://wsdot.wa.gov/travel/highways-bridges/hood-canal-bridge
      Scheduled opening 10:15 for the tug Salish Pontoon, eastbound with a pontoon section.
      Highway closed 10:00 to 10:40.
      The tug needs the span open from 10:15 to 10:30.
      Does the posted opening cover Salish Pontoon's 10:15 to 10:30 window?
    TEXT

    BUS_QUESTION = "The Poulsbo school bus has to be at the east abutment by 10:35 for the Chimacum run. If it waits at the abutment, does it still sit through the 10:40 reopen?"

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
      opening = chat.ask(OPENING_QUESTION)

      relief = relief_model
      chat.with_model(
        relief.fetch(:model),
        provider: relief.fetch(:provider),
        assume_model_exists: relief[:assume_model_exists] || false
      )
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      bus = chat.ask(BUS_QUESTION)

      Result.new(
        opening: opening.content,
        opening_model: opening.model,
        bus: bus.content,
        bus_model: bus.model,
        chat_model_id: chat.model.id,
        roles: chat.messages.map(&:role),
        first_user_still_present: chat.messages.any? { |message|
          message.role == :user && message.content.include?("Salish Pontoon")
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
  Multivitamin::Cassettes.play(__dir__, "opening_switch") do
    result = HoodCanalBridge::OpeningSwitch.conduct
  end

  puts "#{result.opening_model}: #{result.opening}"
  puts
  puts "#{result.bus_model}: #{result.bus}"
end
