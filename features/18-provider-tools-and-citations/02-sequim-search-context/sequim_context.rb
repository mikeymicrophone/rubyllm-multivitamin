# frozen_string_literal: true

# Provider tools and citations · 02 · Sequim search context
#
# Teaches:
# - with_provider_tools(web_search: { ... }) merges options onto the tool.
# - filters / allowed_domains are a BadRequestError on gpt-4.1-mini.
# - search_context_size: "low" is accepted and the search still cites.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SequimSearchContext
  # The tide clerk at Sequim Bay wants NOAA pages only. This model rejects
  # domain filters, so the desk falls back to a small search context.
  class SequimContext
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Sequim Bay.
      Call web search. Answer in two short sentences.
      Name Sequim Bay and the tender Alden.
      Cite the URL you used.
      Do not invent a tide height.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Sequim Bay entrance.
      Search NOAA Tides and Currents for Sequim Bay tide predictions.
      Catalog: https://tidesandcurrents.noaa.gov/
      Alden copies the nearest gauge before crossing the spit.
      Which NOAA page should the clerk post, and what does it call the station?
    TEXT

    Result = Struct.new(
      :filter_error,
      :filter_message,
      :brief,
      :citation_urls,
      :search_requests,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      filter_error = nil
      begin
        filtered = open_chat
        filtered.with_instructions(INSTRUCTIONS)
        filtered.with_provider_tools(web_search: { filters: { allowed_domains: ["tidesandcurrents.noaa.gov"] } })
        filtered.ask(QUESTION)
      rescue RubyLLM::BadRequestError => raised
        filter_error = raised
      end

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(web_search: { search_context_size: "low" })
      brief = chat.ask(QUESTION)

      Result.new(
        filter_error: filter_error.class.name,
        filter_message: filter_error&.message,
        brief: brief.content,
        citation_urls: brief.citations.map(&:url),
        search_requests: brief.tokens.server_tool_use&.[]("web_search_requests"),
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
  Multivitamin::Cassettes.play(__dir__, "sequim_context") do
    result = SequimSearchContext::SequimContext.conduct
  end

  puts result.filter_error
  puts result.filter_message
  puts result.brief
end
