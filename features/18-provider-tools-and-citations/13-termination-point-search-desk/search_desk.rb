# frozen_string_literal: true

# Provider tools and citations · 13 · Termination Point search desk capstone
#
# Teaches:
# - One agent can declare web_search and code_execution together.
# - The first ask hails NOAA and fills citations.
# - The second ask interpolates the kelp-ledge height on the same desk.
# - server_tool_calls from both turns stay on their own messages.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TerminationPointSearchDesk
  # The overnight desk at Termination Point, at the mouth of Liberty Bay,
  # hails NOAA, then interpolates Alden's clearance before the relief
  # copies the card.
  class WatchDesk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    provider_tools :web_search, :code_execution
    temperature 0.2

    instructions <<~TEXT.strip
      You are the watch clerk at Termination Point on Liberty Bay.
      On the first question, call web search and cite the NOAA page.
      On the second question, use code execution and include the exact height.
      Name Termination Point and the tender Alden in every answer.
      Do not invent a station id or a different formula.
    TEXT
  end

  class SearchDesk
    HAIL = <<~TEXT.strip
      Thursday 15 October 2026, Termination Point overnight desk.
      Search NOAA Tides and Currents for station 9444900, the Port Townsend
      gauge this desk copies.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Which page names that gauge, and what does it call the station?
    TEXT

    INTERP = <<~TEXT.strip
      Use code execution. Minutes from midnight: 06:42 is 402, 12:18 is 738,
      10:46 is 646. Posted heights: 0.4 ft at 06:42, 8.1 ft at 12:18.
      Compute 0.4 + (8.1 - 0.4) * (646 - 402) / (738 - 402).
      Print the exact number. Does Alden have 6.0 ft at 10:46 at Termination Point?
    TEXT

    Result = Struct.new(
      :hail,
      :height,
      :citation_urls,
      :hail_calls,
      :height_calls,
      :roles,
      :declared_tools,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      agent = open_agent
      hail = agent.ask(HAIL)
      height = agent.ask(INTERP)

      Result.new(
        hail: hail.content,
        height: height.content,
        citation_urls: hail.citations.map(&:url),
        hail_calls: hail.server_tool_calls.map(&:type),
        height_calls: height.server_tool_calls.map(&:type),
        roles: agent.messages.map(&:role),
        declared_tools: WatchDesk.provider_tools,
        cost: height.cost.total
      )
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = WatchDesk.new(model: chosen[:model], **kwargs)
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
  Multivitamin::Cassettes.play(__dir__, "search_desk") do
    result = TerminationPointSearchDesk::SearchDesk.conduct
  end

  puts result.hail
  puts
  puts result.height
end
