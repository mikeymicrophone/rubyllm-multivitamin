# frozen_string_literal: true

# Provider tools and citations · 10 · Double Bluff citations off
#
# Teaches:
# - with_citations then with_citations(false) clears the document flag.
# - nil is ArgumentError. The flag is only true or false.
# - Web search citations still arrive. They do not use that flag.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DoubleBluffCitationsOff
  # The clerk at Double Bluff, on the southwest shore of Whidbey, turns
  # document citations off, then still has to hail NOAA. Search citations
  # land anyway.
  class CitationsOff
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Double Bluff.
      Call web search. Answer in two short sentences.
      Name Double Bluff and the tender Alden.
      Cite the NOAA page you used.
      Do not invent a station id.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Double Bluff.
      Search NOAA Tides and Currents for station 9444900, the Port Townsend
      gauge Double Bluff copies.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Which page names that gauge?
    TEXT

    Result = Struct.new(
      :nil_error,
      :citations_flag,
      :brief,
      :citation_urls,
      :call_types,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_citations
      nil_error = nil
      begin
        chat.with_citations(nil)
      rescue ArgumentError => raised
        nil_error = raised
      end
      chat.with_citations(false)
      chat.with_provider_tools(:web_search)
      brief = chat.ask(QUESTION)

      Result.new(
        nil_error: nil_error&.message,
        citations_flag: chat.citations,
        brief: brief.content,
        citation_urls: brief.citations.map(&:url),
        call_types: brief.server_tool_calls.map(&:type),
        cost: brief.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "citations_off") do
    result = DoubleBluffCitationsOff::CitationsOff.conduct
  end

  puts result.brief
  puts result.citation_urls
end
