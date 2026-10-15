# frozen_string_literal: true

# Provider tools and citations · 07 · Lagoon Point file search
#
# Teaches:
# - file_search needs vector_store_ids on OpenAI. The store is a provider
#   resource, not a RubyLLM object.
# - Missing ids raise BadRequestError before a useful answer.
# - A prepared store cites the uploaded Lagoon Point card by filename.

require "json"
require "logger"
require "net/http"
require "ruby_llm"
require "uri"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LagoonPointFileSearch
  # The clerk at Lagoon Point, on the west shore of Whidbey, files the
  # posted card into an OpenAI vector store so file_search can cite it.
  class LagoonStore
    CARD = File.expand_path("lagoon-point-card.txt", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Lagoon Point.
      Search the posted card. Answer in two short sentences.
      Name Lagoon Point, Alden, and 10:46.
      Do not invent a tide height.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Lagoon Point kelp ledge.
      From the posted card, when does Alden clear the kelp ledge?
    TEXT

    Result = Struct.new(
      :missing_ids_error,
      :brief,
      :citation_titles,
      :citation_source_ids,
      :call_types,
      :store_id,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      missing = nil
      begin
        bare = open_chat
        bare.with_instructions(INSTRUCTIONS)
        bare.with_provider_tools(:file_search)
        bare.ask(QUESTION)
      rescue RubyLLM::BadRequestError => raised
        missing = raised
      end

      uploaded = RubyLLM.upload(
        CARD,
        provider: :openai,
        purpose: "user_data",
        filename: "lagoon-point-card.txt"
      )
      store_id = create_store
      attach_and_wait(store_id, uploaded.id)

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_provider_tools(file_search: { vector_store_ids: [store_id] })
      brief = chat.ask(QUESTION)

      Result.new(
        missing_ids_error: missing&.message,
        brief: brief.content,
        citation_titles: brief.citations.map(&:title),
        citation_source_ids: brief.citations.map(&:source_id),
        call_types: brief.server_tool_calls.map(&:type),
        store_id: store_id,
        cost: brief.cost.total
      )
    ensure
      delete_store(store_id) if store_id
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

    def self.create_store
      code, body = json_request(
        "Post",
        "/v1/vector_stores",
        name: "lagoon-point-cards",
        expires_after: { anchor: "last_active_at", days: 1 }
      )
      raise "vector store create failed: #{code} #{body}" unless body["id"]

      body.fetch("id")
    end

    def self.attach_and_wait(store_id, file_id)
      _code, attached = json_request(
        "Post",
        "/v1/vector_stores/#{store_id}/files",
        file_id: file_id
      )
      attached_id = attached.fetch("id")
      20.times do
        _code, status = json_request(
          "Get",
          "/v1/vector_stores/#{store_id}/files/#{attached_id}"
        )
        return if status["status"] == "completed"
        raise "vector store file failed: #{status}" if status["status"] == "failed"

        sleep 1 if ENV["LIVE"] == "1"
      end
      raise "vector store file did not complete"
    end

    def self.delete_store(store_id)
      json_request("Delete", "/v1/vector_stores/#{store_id}")
    rescue StandardError
      nil
    end

    def self.json_request(method, path, **body)
      uri = URI("https://api.openai.com#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP.const_get(method).new(uri)
      request["Authorization"] = "Bearer #{ENV.fetch("OPENAI_API_KEY")}"
      request["Content-Type"] = "application/json"
      request.body = JSON.dump(body) unless body.empty? || method == "Get" || method == "Delete"
      response = http.request(request)
      parsed = response.body.to_s.empty? ? {} : JSON.parse(response.body)
      [response.code, parsed]
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
  Multivitamin::Cassettes.play(__dir__, "lagoon_store") do
    result = LagoonPointFileSearch::LagoonStore.conduct
  end

  puts result.brief
  puts result.citation_titles
end
