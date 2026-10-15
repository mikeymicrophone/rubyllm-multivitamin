# frozen_string_literal: true

# Agents · 01 · Point Wilson tide clerk
#
# Teaches:
# - A RubyLLM::Agent subclass declares model and instructions once.
# - Agent.new.ask runs that setup. The class macros stay on the class.
# - Agent.chat returns a RubyLLM::Chat, not an Agent.
# - Recorded on OpenAI gpt-4.1-mini after the free OpenRouter daily cap.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonTideClerk
  # The incoming watch at Point Wilson reads two questions off the posted
  # tide board. The clerk is an agent, not a one-off chat chain.
  class TideClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai

    instructions <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Brief the incoming watch in short sentences.
      Use only the tide board in the question.
      Name the boats Alden and Retort.
      Do not invent tide heights.
    TEXT

    temperature 0.2
  end

  class WatchBrief
    BOARD_QUESTION = <<~TEXT.strip
      Tide board posted for Wednesday 15 October 2026 at Point Wilson.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      The foghorn tender Alden needs 6.0 ft at the float to clear the kelp ledge.
      The cannery tender Retort, up from the Anacortes cannery, can use the float at 3.5 ft.
      Alden clears the kelp ledge at 10:46.
      Retort can use the float at 08:57.
      When can Alden leave the float this morning, and when can Retort?
    TEXT

    LENS_QUESTION = "The lens cabinet stays open until 09:30. Should the watch hail the lens crew before Alden sails?"

    Result = Struct.new(
      :opening,
      :follow_up,
      :roles,
      :agent_class,
      :declared_model,
      :opening_finish,
      :opening_input_tokens,
      :opening_cost,
      keyword_init: true
    )

    def self.conduct
      configure
      agent = open_agent
      opening = agent.ask(BOARD_QUESTION)
      follow_up = agent.ask(LENS_QUESTION)

      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        roles: agent.messages.map(&:role),
        agent_class: agent.class.name,
        declared_model: TideClerk.model.fetch(:model),
        opening_finish: opening.finish_reason,
        opening_input_tokens: opening.tokens.input,
        opening_cost: opening.cost.total
      )
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = TideClerk.new(model: chosen[:model], **kwargs)
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
  Multivitamin::Cassettes.play(__dir__, "tide_clerk") do
    result = PointWilsonTideClerk::WatchBrief.conduct
  end

  puts result.opening
  puts
  puts result.follow_up
end
