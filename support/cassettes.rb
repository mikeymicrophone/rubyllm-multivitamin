# frozen_string_literal: true

require "fileutils"
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
    ].freeze

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
      VCR.use_cassette(
        name,
        record: live? ? :all : :none,
        match_requests_on: %i[method uri body],
        drop_unused_requests: live?
      ) { yield }
    ensure
      VCR.configure { |config| config.cassette_library_dir = previous } if previous
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
      end

      @configured = true
    end

    def scrub_interaction(interaction)
      scrub_headers(interaction.request.headers)
      scrub_headers(interaction.response.headers)
      interaction.request.body = scrub_text(interaction.request.body)
      interaction.response.body = scrub_text(interaction.response.body)
    end

    def scrub_headers(headers)
      return unless headers

      headers.delete_if { |name, _| name.to_s.downcase == "set-cookie" }
      authorization = headers.keys.find { |name| name.to_s.downcase == "authorization" }
      headers[authorization] = ["Bearer #{authorization_placeholder(Array(headers[authorization]).join)}"] if authorization
    end

    def authorization_placeholder(token)
      return OPENAI_FILTERED_KEY if token.include?(OPENAI_FILTERED_KEY)
      return FILTERED_KEY if token.include?(FILTERED_KEY)

      openai = ENV["OPENAI_API_KEY"].to_s
      openrouter = ENV["OPENROUTER_API_KEY"].to_s
      return OPENAI_FILTERED_KEY if openai.length > 8 && openai != PLACEHOLDER_KEY && token.include?(openai)
      return FILTERED_KEY if openrouter.length > 8 && openrouter != PLACEHOLDER_KEY && token.include?(openrouter)
      return FILTERED_KEY if token.match?(/sk-or-/)
      return OPENAI_FILTERED_KEY if token.match?(/sk-/)

      FILTERED_KEY
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
