# frozen_string_literal: true

# Agents · 11 · Port Angeles net loft switch
#
# Teaches:
# - with_model on an agent instance switches the slug mid-run.
# - The earlier twine question stays on the transcript.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortAngelesNetLoftSwitch
  class TwineClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2

    instructions <<~TEXT.strip
      You are the twine clerk in the Port Angeles net loft.
      Answer in one short sentence from the twine ticket only.
      Name 3-strand tarred nylon and spool 14.
    TEXT
  end

  class TwineTicket
    TICKET_QUESTION = <<~TEXT.strip
      Port Angeles net loft twine ticket, Wednesday 15 October 2026.
      Loft notes: https://www.portofpa.com/
      Spool 14, 3-strand tarred nylon, 1200 feet remaining.
      What twine does the mending bench pull?
    TEXT

    SPOOL_QUESTION = "The bench asks for spool 14 again. How many feet remain?"

    Result = Struct.new(
      :opening,
      :follow_up,
      :opening_model,
      :follow_up_model,
      :switched_chat_model,
      :first_user_still_present,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      agent = open_agent
      opening = agent.ask(TICKET_QUESTION)
      relief = switch_model
      agent.with_model(
        relief.fetch(:model),
        provider: relief.fetch(:provider),
        assume_model_exists: relief[:assume_model_exists] || false
      )
      follow_up = agent.ask(SPOOL_QUESTION)

      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        opening_model: opening.model,
        follow_up_model: follow_up.model,
        switched_chat_model: agent.model.id,
        first_user_still_present: agent.messages.any? { |message|
          message.role == :user && message.content.include?("3-strand tarred nylon")
        },
        roles: agent.messages.map(&:role)
      )
    end

    def self.switch_model
      case Multivitamin::Models.recording_provider(:openai)
      when :openrouter
        {
          model: Multivitamin::Models::CHAT_FALLBACK,
          provider: :openrouter,
          assume_model_exists: true
        }
      else
        { model: Multivitamin::Models::OPENAI_CHAT_SWITCH, provider: :openai }
      end
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = TwineClerk.new(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(agent, provider: :openai)
      agent
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
  Multivitamin::Cassettes.play(__dir__, "net_switch") do
    result = PortAngelesNetLoftSwitch::TwineTicket.conduct
  end

  puts result.opening
  puts
  puts result.follow_up
end
