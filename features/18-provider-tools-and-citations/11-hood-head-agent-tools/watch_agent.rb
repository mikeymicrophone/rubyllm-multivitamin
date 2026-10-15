# frozen_string_literal: true

# Provider tools and citations · 11 · Hood Head agent provider tools
#
# Teaches:
# - An Agent subclass declares provider_tools :web_search.
# - Agent.new.ask runs that search without a separate with_provider_tools.
# - Agent.chat returns a RubyLLM::Chat, not an Agent.
# - A second ask on the same agent keeps the earlier hail.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HoodHeadAgentTools
  # The clerk at Hood Head, on the west shore of Hood Canal, is an agent
  # whose only extra tool is provider-hosted web search.
  class WatchClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    provider_tools :web_search
    temperature 0.2

    instructions <<~TEXT.strip
      You are the tide clerk at Hood Head on Hood Canal.
      Call web search on the first question.
      Answer in two short sentences.
      The first sentence of every answer must contain the exact words Hood Head and Alden.
      Cite the NOAA page you used.
      Do not invent a station id.
    TEXT
  end

  class WatchBrief
    BOARD_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Hood Head.
      Search NOAA Tides and Currents for station 9444900, the Port Townsend
      gauge Hood Head copies for Admiralty Inlet.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Which page names that gauge, and what does it call the station?
    TEXT

    LENS_QUESTION = "Should the Hood Head watch hail the lens crew before Alden copies that gauge at 10:46 if the cabinet stays open until 09:30?"

    Result = Struct.new(
      :opening,
      :follow_up,
      :citation_urls,
      :call_types,
      :roles,
      :agent_class,
      :declared_tools,
      :cost,
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
        citation_urls: opening.citations.map(&:url),
        call_types: opening.server_tool_calls.map(&:type),
        roles: agent.messages.map(&:role),
        agent_class: agent.class.name,
        declared_tools: WatchClerk.provider_tools,
        cost: follow_up.cost.total
      )
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = WatchClerk.new(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(agent, provider: :openai)
      agent
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
  Multivitamin::Cassettes.play(__dir__, "watch_agent") do
    result = HoodHeadAgentTools::WatchBrief.conduct
  end

  puts result.opening
  puts
  puts result.follow_up
end
