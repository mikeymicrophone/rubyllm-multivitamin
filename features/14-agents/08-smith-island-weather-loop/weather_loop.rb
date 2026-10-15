# frozen_string_literal: true

# Agents · 08 · Smith Island weather loop
#
# Teaches:
# - complete? is true on a new agent. Nothing is staged.
# - ask_later appends the user turn and returns the wrapped Chat.
# - step generates once. complete? is then true. A second step is nil.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SmithIslandWeatherLoop
  class WeatherClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2

    instructions <<~TEXT.strip
      You are the weather clerk at Smith Island Light.
      Answer in one short sentence from the barometer card only.
      Name 29.84 inches and the falling glass.
    TEXT
  end

  class BarometerRound
    CARD_QUESTION = <<~TEXT.strip
      Smith Island barometer card, Wednesday 15 October 2026.
      Station notes: https://www.nps.gov/places/smith-island-light-station.htm
      Glass 29.84 inches, falling. The incoming watch wants the posted glass.
      What does the clerk post?
    TEXT

    Result = Struct.new(
      :brief,
      :complete_before_later,
      :complete_after_later,
      :later_class,
      :step_role,
      :complete_after_step,
      :second_step,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      agent = open_agent
      complete_before_later = agent.complete?
      later = agent.ask_later(CARD_QUESTION)
      complete_after_later = agent.complete?
      step_message = agent.step
      complete_after_step = agent.complete?
      second_step = agent.step

      Result.new(
        brief: step_message&.content,
        complete_before_later: complete_before_later,
        complete_after_later: complete_after_later,
        later_class: later.class.name,
        step_role: step_message&.role,
        complete_after_step: complete_after_step,
        second_step: second_step,
        roles: agent.messages.map(&:role)
      )
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = WeatherClerk.new(model: chosen[:model], **kwargs)
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
  Multivitamin::Cassettes.play(__dir__, "weather_loop") do
    result = SmithIslandWeatherLoop::BarometerRound.conduct
  end

  puts result.brief
end
