# frozen_string_literal: true

# Provider tools and citations · 01 · Diamond Point web search hail
#
# Teaches:
# - with_provider_tools(:web_search) sends type web_search on Responses.
# - The reply carries Citation objects on response.citations.
# - server_tool_calls records a web_search_call.
# - tokens.server_tool_use counts web_search_requests.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DiamondPointWebSearch
  # The radio clerk at Diamond Point, on the west shore of Discovery Bay,
  # has to hail NOAA for the Port Townsend gauge before Alden leaves the
  # kelp ledge. The search runs on the provider, not as a local tool.
  class DiamondSearch
    INSTRUCTIONS = <<~TEXT.strip
      You are the radio clerk at Diamond Point on Discovery Bay.
      Call web search. Answer in two short sentences.
      The first sentence must contain the exact words Diamond Point and Alden.
      Include a markdown link to the NOAA page you used.
      Do not invent a station id.
    TEXT

    HAIL = <<~TEXT.strip
      Thursday 15 October 2026, morning watch at Diamond Point.
      Search NOAA Tides and Currents for station 9444900, the Port Townsend
      gauge the Diamond Point clerk copies for Admiralty Inlet.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      When Alden leaves the kelp ledge this morning, which NOAA page names
      that gauge, and what does the page call the station?
      Start with Diamond Point and Alden. End with a markdown link to the NOAA page.
    TEXT

    Result = Struct.new(
      :hail,
      :citation_urls,
      :citation_class,
      :call_types,
      :search_requests,
      :roles,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(:web_search)
      hail = chat.ask(HAIL)

      Result.new(
        hail: hail.content,
        citation_urls: hail.citations.map(&:url),
        citation_class: hail.citations.first&.class&.name,
        call_types: hail.server_tool_calls.map(&:type),
        search_requests: hail.tokens.server_tool_use&.[]("web_search_requests"),
        roles: chat.messages.map(&:role),
        cost: hail.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "diamond_search") do
    result = DiamondPointWebSearch::DiamondSearch.conduct
  end

  puts result.hail
  puts result.citation_urls
end
