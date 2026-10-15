# frozen_string_literal: true

# Provider tools and citations · 04 · Marrowstone SearchResults RAG
#
# Teaches:
# - A RubyLLM::Tool can return RubyLLM::SearchResults.
# - On OpenAI that becomes JSON on the :tool message, key search_results.
# - SearchResults.from_content reads that JSON back.
# - response.citations stays empty: OpenAI does not cite tool passages.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MarrowstoneSearchResults
  # The kelp-ledge cabinet at Marrowstone Point is a stack of posted
  # cards. The clerk searches that cabinet, not the web.
  class KelpLedgeCabinet < RubyLLM::Tool
    description "Searches the posted kelp-ledge cards at Marrowstone Point"

    def self.tool_name
      "kelp_ledge_cabinet"
    end

    parameter :query, description: "What to look for on the posted cards"

    CARDS = [
      {
        title: "Marrowstone kelp ledge card",
        url: "https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900",
        text: "Marrowstone Point posted card for Thursday 15 October 2026. Alden clears the kelp ledge at 10:46. Low water 06:42, 0.4 ft above MLLW."
      },
      {
        title: "Marrowstone lens cabinet latch",
        url: "https://www.historylink.org/File/20216",
        text: "The Fresnel lens crew is in the Marrowstone cabinet until 09:30. Do not hail them before Alden sails."
      }
    ].freeze

    def execute(query:)
      hits = CARDS.select { |card| card.fetch(:text).downcase.include?(query.to_s.downcase.split.first.to_s) }
      hits = CARDS if hits.empty?
      RubyLLM::SearchResults.new(*hits)
    end
  end

  class KelpCards
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Marrowstone Point.
      Call kelp_ledge_cabinet once. Answer in two short sentences from those cards.
      Name Alden and 10:46. Do not invent a tide height.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Marrowstone Point kelp ledge.
      Search the posted cards: when does Alden clear the kelp ledge?
    TEXT

    Result = Struct.new(
      :brief,
      :tool_content,
      :parsed_titles,
      :citations,
      :roles,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_tools(KelpLedgeCabinet)
      chat.with_tool_options(choice: KelpLedgeCabinet)
      brief = chat.ask(QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }
      parsed = RubyLLM::SearchResults.from_content(tool_message&.content.to_s)

      Result.new(
        brief: brief.content,
        tool_content: tool_message&.content,
        parsed_titles: parsed&.results&.map { |entry| entry[:title] } || [],
        citations: brief.citations,
        roles: chat.messages.map(&:role),
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
  Multivitamin::Cassettes.play(__dir__, "kelp_cards") do
    result = MarrowstoneSearchResults::KelpCards.conduct
  end

  puts result.brief
  puts result.tool_content
end
