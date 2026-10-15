# frozen_string_literal: true

# Provider tools and citations · 09 · Useless Bay unknown alias
#
# Teaches:
# - :web_fetch raises UnsupportedServerToolError on OpenAI before HTTP.
# - The message lists the aliases this protocol actually has.
# - A raw Hash is how an unlisted tool would be sent.
# - :web_search still hails NOAA after the refusal.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module UselessBayUnknownAlias
  # The clerk at Useless Bay, south of Mutiny Bay, first asks OpenAI to
  # fetch a NOAA page. That alias is not on Responses. The desk searches
  # instead.
  class FetchAlias
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Useless Bay.
      Call web search. Answer in two short sentences.
      Name Useless Bay and the tender Alden.
      Cite the NOAA page you used.
      Do not invent a station id.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Useless Bay.
      Search NOAA Tides and Currents for station 9444900, the Port Townsend
      gauge Useless Bay copies.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Which page names that gauge?
    TEXT

    Result = Struct.new(
      :fetch_error,
      :fetch_message,
      :known_aliases,
      :brief,
      :citation_urls,
      :call_types,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      fetch_error = nil
      begin
        refused = open_chat
        refused.with_instructions(INSTRUCTIONS)
        refused.with_provider_tools(:web_fetch)
        refused.ask(QUESTION)
      rescue RubyLLM::UnsupportedServerToolError => raised
        fetch_error = raised
      end

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(:web_search)
      brief = chat.ask(QUESTION)

      Result.new(
        fetch_error: fetch_error.class.name,
        fetch_message: fetch_error&.message,
        known_aliases: fetch_error&.message.to_s[/Known aliases: (.+?)\./, 1].to_s.scan(/:([a-z_]+)/).flatten,
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
  Multivitamin::Cassettes.play(__dir__, "fetch_alias") do
    result = UselessBayUnknownAlias::FetchAlias.conduct
  end

  puts result.fetch_message
  puts result.brief
end
