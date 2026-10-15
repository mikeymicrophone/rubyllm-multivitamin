# frozen_string_literal: true

# Provider tools and citations · 12 · Tala Point citation indexes
#
# Teaches:
# - OpenAI web_search citations carry start_index and end_index.
# - content[start_index...end_index] equals citation.text.
# - to_h omits nil fields. url and title stay.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TalaPointCitationIndexes
  # The clerk at Tala Point, on the west shore of Hood Canal, posts
  # footnote marks on the NOAA hail so the relief can open the cited span.
  class IndexMarks
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Tala Point on Hood Canal.
      Call web search. Answer in two short sentences.
      Begin the answer with: At Tala Point, Alden copies this gauge.
      Include a markdown link to the NOAA page you used.
      Do not invent a station id.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Tala Point.
      Search NOAA Tides and Currents for station 9444900, the Port Townsend
      gauge Tala Point copies.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Which page names that gauge, and what does it call the station?
      Start with Tala Point and Alden. End with a markdown link to the NOAA page.
    TEXT

    Result = Struct.new(
      :brief,
      :citations,
      :spans,
      :hashes,
      :call_types,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(:web_search)
      brief = chat.ask(QUESTION)

      spans = brief.citations.map do |citation|
        next unless citation.start_index && citation.end_index

        brief.content[citation.start_index...citation.end_index]
      end

      Result.new(
        brief: brief.content,
        citations: brief.citations,
        spans: spans,
        hashes: brief.citations.map(&:to_h),
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
  Multivitamin::Cassettes.play(__dir__, "index_marks") do
    result = TalaPointCitationIndexes::IndexMarks.conduct
  end

  puts result.brief
  result.hashes.each { |row| puts row.inspect }
end
