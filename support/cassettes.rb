# frozen_string_literal: true

require "base64"
require "fileutils"
require "json"
require "securerandom"
require "vcr"
require "webmock"

module Multivitamin
  # Plays a scenario's cassette from that scenario's own cassettes/ directory.
  # LIVE=1 records a fresh cassette against the network. Anything else replays
  # and refuses a request the cassette does not already answer.
  module Cassettes
    PLACEHOLDER_KEY = "cassette-placeholder-not-a-real-key"
    FILTERED_KEY = "<OPENROUTER_API_KEY>"
    OPENAI_FILTERED_KEY = "<OPENAI_API_KEY>"

    KEY_ENV_VARS = %w[
      OPENROUTER_API_KEY
      OPENAI_API_KEY
      ANTHROPIC_API_KEY
      GEMINI_API_KEY
      XAI_API_KEY
      MISTRAL_API_KEY
      COHERE_API_KEY
      DEEPSEEK_API_KEY
      PERPLEXITY_API_KEY
      MCP_BEARER_TOKEN
      MCP_CLIENT_SECRET
      MCP_OAUTH_ACCESS_TOKEN
      VERTEXAI_ACCESS_TOKEN
    ].freeze

    # 1x1 PNG and JPEG stand-ins so image cassettes do not store megabytes
    # of b64_json. Not scenario copy.
    TINY_PNG = Base64.decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
    ).freeze
    TINY_JPEG = Base64.decode64(
      "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDAREAAhEBAxEB/8QAFAABAAAAAAAAAAAAAAAAAAAACP/EABQQAQAAAAAAAAAAAAAAAAAAAAD/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8AfwD/2Q=="
    ).freeze
    B64_JSON_KEEP_BYTES = 512

    # Faraday::Multipart calls SecureRandom.hex for the form boundary.
    # VCR matches on body, so a random boundary would fail on replay.
    # Not scenario copy.
    MULTIPART_BOUNDARY_HEX = "multivitamin000000000000000000"

    # Short silent clips so speech cassettes do not store kilobytes of
    # MPEG or WAV. Not scenario copy. MP3 starts with a frame sync so
    # replay still looks like OpenAI's tts-1 payload.
    TINY_MP3 = Base64.decode64(
      "/+MYxAAAAANIAAAAAExBTUUzLjEwMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV/+MYxDsAAANIAAAAAFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV/+MYxHYAAANIAAAAAFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV"
    ).freeze
    TINY_WAV = Base64.decode64(
      "UklGRiYAAABXQVZFZm10IBAAAAABAAEAQB8AAIA+AAACABAAZGF0YQIAAAAAAA=="
    ).freeze
    AUDIO_KEEP_BYTES = 512

    module_function

    def live?
      ENV["LIVE"] == "1"
    end

    def play(directory, name)
      prepare_key!
      configure!
      library = File.join(directory, "cassettes")
      FileUtils.mkdir_p(library)

      previous = VCR.configuration.cassette_library_dir
      VCR.configure { |config| config.cassette_library_dir = library }
      # drop_unused_requests makes a live run replace the cassette. Without it,
      # VCR keeps an old interaction whose request body no longer matches.
      pin_vertexai_credentials do
        pin_multipart_boundary do
          VCR.use_cassette(
            name,
            record: live? ? :all : :none,
            match_requests_on: %i[method uri jsonrpc_body],
            drop_unused_requests: live?
          ) { yield }
        end
      end
    ensure
      VCR.configure { |config| config.cassette_library_dir = previous } if previous
    end

    def pin_multipart_boundary
      singleton = SecureRandom.singleton_class
      original = singleton.instance_method(:hex)
      singleton.define_method(:hex) do |n = nil|
        n.nil? ? MULTIPART_BOUNDARY_HEX : original.bind_call(self, n)
      end
      yield
    ensure
      singleton.define_method(:hex, original) if singleton && original
    end

    # Replay never asks ADC/googleauth for a token. Scope the replacement to
    # playback and restore it even when a scenario raises. Live uses real ADC.
    def pin_vertexai_credentials
      return yield if live?

      require "ruby_llm"
      provider = RubyLLM::Providers::VertexAI
      original = provider.instance_method(:headers)
      provider.define_method(:headers) { { "Authorization" => "Bearer <VERTEXAI_ACCESS_TOKEN>" } }
      yield
    ensure
      provider.define_method(:headers, original) if provider && original
    end

    def prepare_key!
      if live?
        require_live_key!
        return
      end

      ENV["OPENROUTER_API_KEY"] ||= PLACEHOLDER_KEY
      ENV["OPENAI_API_KEY"] ||= PLACEHOLDER_KEY
    end

    def require_live_key!
      provider = ENV["LIVE_PROVIDER"].to_s.strip.downcase
      case provider
      when "openai"
        return unless ENV["OPENAI_API_KEY"].to_s.empty?

        abort "LIVE=1 LIVE_PROVIDER=openai needs OPENAI_API_KEY in the environment. Never commit it."
      when "openrouter"
        return unless ENV["OPENROUTER_API_KEY"].to_s.empty?

        abort "LIVE=1 LIVE_PROVIDER=openrouter needs OPENROUTER_API_KEY in the environment. Never commit it."
      when ""
        return unless ENV["GOOGLE_CLOUD_PROJECT"].to_s.empty?
        return unless ENV["OPENROUTER_API_KEY"].to_s.empty? && ENV["OPENAI_API_KEY"].to_s.empty?

        abort "LIVE=1 needs OPENROUTER_API_KEY or OPENAI_API_KEY in the environment. Never commit it."
      else
        abort "LIVE_PROVIDER must be openai or openrouter."
      end
    end

    def configure!
      return if @configured

      VCR.configure do |config|
        config.hook_into :webmock
        config.allow_http_connections_when_no_cassette = false
        config.default_cassette_options = { record: :none }

        KEY_ENV_VARS.each do |name|
          config.filter_sensitive_data("<#{name}>") { ENV[name] }
        end

        config.before_record do |interaction|
          scrub_interaction(interaction)
        end

        # MCP JSON-RPC request ids are SecureRandom.uuid. Match after
        # stripping them, then copy the live id onto the recorded answer
        # so RubyLLM::MCP::HTTP::Stream can find it.
        config.before_http_request do |request|
          Thread.current[:multivitamin_jsonrpc_id] = jsonrpc_id(request.body)
        end

        config.register_request_matcher :jsonrpc_body do |request_one, request_two|
          normalize_jsonrpc_body(request_one.body) == normalize_jsonrpc_body(request_two.body)
        end

        config.before_playback do |interaction|
          sync_jsonrpc_response_id!(interaction, Thread.current[:multivitamin_jsonrpc_id])
        end
      end

      patch_mcp_jsonrpc_ids!
      @configured = true
    end

    # RubyLLM::MCP::HTTP::Stream looks up the answer by request id.
    # Recorded JSON-RPC bodies keep the UUID from the live call, so replay
    # would miss the result and fall back to the initialize handshake.
    def patch_mcp_jsonrpc_ids!
      require "ruby_llm"
      return if RubyLLM::MCP::HTTP::Stream.instance_variable_get(:@multivitamin_jsonrpc_id_patch)

      RubyLLM::MCP::HTTP::Stream.prepend(Module.new do
        def answer
          found = super
          return found if found

          unmatched = replies.find { |reply| !reply.key?("method") }
          return unless unmatched

          unmatched["id"] = id
          unmatched
        end
      end)
      RubyLLM::MCP::HTTP::Stream.instance_variable_set(:@multivitamin_jsonrpc_id_patch, true)
    end

    def scrub_interaction(interaction)
      scrub_headers(interaction.request.headers)
      if interaction.request.uri.to_s.include?("aiplatform.googleapis.com/")
        authorization = interaction.request.headers.keys.find { |name| name.to_s.downcase == "authorization" }
        interaction.request.headers[authorization] = ["Bearer <VERTEXAI_ACCESS_TOKEN>"] if authorization
      end
      scrub_headers(interaction.response.headers)
      interaction.request.body = scrub_text(interaction.request.body)
      interaction.response.body = shrink_image_payload(scrub_text(interaction.response.body))
      shrink_audio_payload!(interaction)
    end

    def shrink_audio_payload!(interaction)
      body = interaction.response.body
      return unless body.is_a?(String) && body.bytesize > AUDIO_KEEP_BYTES
      return unless interaction.request.uri.to_s.include?("/audio/speech")

      headers = interaction.response.headers
      content_type = ""
      headers&.each do |name, value|
        content_type = Array(value).join if name.to_s.downcase == "content-type"
      end
      return if content_type.include?("application/json")
      return if body.lstrip.start_with?("{")

      request_body = interaction.request.body.to_s
      wav = request_body.include?('"response_format":"wav"') ||
            content_type.include?("wav") ||
            body.start_with?("RIFF")
      interaction.response.body = wav ? TINY_WAV : TINY_MP3
    end

    def shrink_image_payload(body)
      return body unless body.is_a?(String)
      return body unless body.include?("b64_json")

      data = JSON.parse(body)
      shrink_b64_json!(data)
      JSON.generate(data)
    rescue JSON::ParserError
      body
    end

    def shrink_b64_json!(node)
      case node
      when Hash
        if node.key?("b64_json") && node["b64_json"].is_a?(String) && node["b64_json"].bytesize > B64_JSON_KEEP_BYTES
          raw = Base64.decode64(node["b64_json"])
          standin = raw.start_with?("\xFF\xD8".b) ? TINY_JPEG : TINY_PNG
          node["b64_json"] = Base64.strict_encode64(standin)
        end
        node.each_value { |value| shrink_b64_json!(value) }
      when Array
        node.each { |value| shrink_b64_json!(value) }
      end
    end

    def scrub_headers(headers)
      return unless headers

      headers.delete_if { |name, _| name.to_s.downcase == "set-cookie" }
      authorization = headers.keys.find { |name| name.to_s.downcase == "authorization" }
      headers[authorization] = ["Bearer #{authorization_placeholder(Array(headers[authorization]).join)}"] if authorization
    end

    def authorization_placeholder(token)
      return "<VERTEXAI_ACCESS_TOKEN>" if token.include?("<VERTEXAI_ACCESS_TOKEN>")
      return OPENAI_FILTERED_KEY if token.include?(OPENAI_FILTERED_KEY)
      return FILTERED_KEY if token.include?(FILTERED_KEY)
      return "<MCP_CLIENT_SECRET>" if token.match?(/\Abasic\s/i) || token.include?("<MCP_CLIENT_SECRET>")
      return "<MCP_BEARER_TOKEN>" if token.include?("<MCP_BEARER_TOKEN>")
      return "<MCP_OAUTH_ACCESS_TOKEN>" if token.include?("<MCP_OAUTH_ACCESS_TOKEN>")

      openai = ENV["OPENAI_API_KEY"].to_s
      openrouter = ENV["OPENROUTER_API_KEY"].to_s
      bearer = ENV["MCP_BEARER_TOKEN"].to_s
      oauth = ENV["MCP_OAUTH_ACCESS_TOKEN"].to_s
      secret = ENV["MCP_CLIENT_SECRET"].to_s
      return OPENAI_FILTERED_KEY if openai.length > 8 && openai != PLACEHOLDER_KEY && token.include?(openai)
      return FILTERED_KEY if openrouter.length > 8 && openrouter != PLACEHOLDER_KEY && token.include?(openrouter)
      return "<MCP_BEARER_TOKEN>" if bearer.length > 4 && token.include?(bearer)
      return "<MCP_OAUTH_ACCESS_TOKEN>" if oauth.length > 4 && token.include?(oauth)
      return "<MCP_CLIENT_SECRET>" if secret.length > 4 && token.include?(secret)
      return FILTERED_KEY if token.match?(/sk-or-/)
      return OPENAI_FILTERED_KEY if token.match?(/sk-/)

      FILTERED_KEY
    end

    def normalize_jsonrpc_body(body)
      text = body.to_s
      return text unless text.include?('"jsonrpc"')

      data = JSON.parse(text)
      strip_jsonrpc_ids!(data)
      JSON.generate(data)
    rescue JSON::ParserError
      text
    end

    def strip_jsonrpc_ids!(node)
      case node
      when Hash
        node["id"] = "<jsonrpc-id>" if node.key?("id")
        node.each_value { |value| strip_jsonrpc_ids!(value) }
      when Array
        node.each { |value| strip_jsonrpc_ids!(value) }
      end
    end

    def jsonrpc_id(body)
      data = JSON.parse(body.to_s)
      data["id"] if data.is_a?(Hash) && data["jsonrpc"]
    rescue JSON::ParserError
      nil
    end

    def sync_jsonrpc_response_id!(interaction, request_id)
      return if request_id.nil?

      body = interaction.response.body
      return unless body.is_a?(String) && body.include?('"jsonrpc"')

      data = JSON.parse(body)
      return unless data.is_a?(Hash) && data.key?("id")

      data["id"] = request_id
      interaction.response.body = JSON.generate(data)
    rescue JSON::ParserError
      nil
    end

    def scrub_text(text)
      return text unless text.is_a?(String)

      scrubbed = text.dup
      KEY_ENV_VARS.each do |name|
        value = ENV[name]
        next if value.nil? || value.empty? || value == PLACEHOLDER_KEY

        scrubbed = scrubbed.gsub(value, "<#{name}>")
      end
      scrubbed = scrubbed.gsub(/sk-or-v1-[A-Za-z0-9_\-]+/, FILTERED_KEY)
      scrubbed.gsub(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, OPENAI_FILTERED_KEY)
    end
  end
end
