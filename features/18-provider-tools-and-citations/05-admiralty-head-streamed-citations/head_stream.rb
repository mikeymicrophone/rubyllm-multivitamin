# frozen_string_literal: true

# Provider tools and citations · 05 · Admiralty Head streamed citations
#
# Teaches:
# - A block on ask yields chunks while web_search runs.
# - Some chunks already carry citations.
# - The completed message has the full, deduplicated list.
# - server_tool_calls on that message still names web_search_call.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyHeadStreamedCitations
  # The lighthouse at Admiralty Head, on the west side of Whidbey, dictates
  # the NOAA hail onto the watch phone while search citations arrive.
  class HeadStream
    INSTRUCTIONS = <<~TEXT.strip
      You are the radio clerk at Admiralty Head on Whidbey Island.
      Call web search. Dictate two short sentences.
      Begin the dictation with: At Admiralty Head, Alden copies this gauge.
      Include a markdown link to the NOAA page you used.
      Do not invent a station id.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Admiralty Head morning watch.
      Search NOAA Tides and Currents for station 9444900, the Port Townsend
      gauge Admiralty Head copies for Admiralty Inlet.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Which page names that gauge, and what does it call the station?
    TEXT

    Result = Struct.new(
      :speech,
      :citations,
      :chunk_citation_urls,
      :chunks_with_citations,
      :call_types,
      :search_requests,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(:web_search)

      chunk_urls = []
      chunks_with_citations = 0
      message = chat.ask(QUESTION) do |chunk|
        urls = chunk.citations.map(&:url).compact
        next if urls.empty?

        chunks_with_citations += 1
        chunk_urls.concat(urls)
      end

      Result.new(
        speech: message.content,
        citations: message.citations,
        chunk_citation_urls: chunk_urls.uniq,
        chunks_with_citations: chunks_with_citations,
        call_types: message.server_tool_calls.map(&:type),
        search_requests: message.tokens.server_tool_use&.[]("web_search_requests"),
        cost: message.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "head_stream") do
    result = AdmiraltyHeadStreamedCitations::HeadStream.conduct
  end

  puts result.speech
  puts result.citations.map(&:url)
end
