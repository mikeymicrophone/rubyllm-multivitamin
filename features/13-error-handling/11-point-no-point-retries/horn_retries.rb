# frozen_string_literal: true

# Error handling · 11 · Point No Point retries
#
# Teaches:
# - Faraday retries Faraday::TimeoutError up to max_retries.
# - The dead circuit is a context, so RubyLLM.config.openrouter_api_base
#   stays unset for later examples.
# - ContextLengthExceededError is not in that list.
# - A dead circuit that never answers is a timeout, not a RubyLLM::Error.

require "logger"
require "ruby_llm"
require "socket"
require "uri"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointNoPointRetries
  # The horn house at Point No Point calls a dead circuit three times —
  # the first POST and two Faraday retries — then gives the watch the
  # timeout. The circuit never speaks. There is no provider cassette.
  class HornRetries
    INSTRUCTIONS = <<~TEXT.strip
      You are the horn clerk at Point No Point Light, Hansville.
      Answer in one short sentence.
      Use only the card in the question.
      Name 3 seconds.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Timing card posted at Point No Point, Thursday 15 October 2026.
      Park page: https://kitsap.gov/parks/point-no-point-lighthouse/.
      Blast 3 seconds, silent 27 seconds.
      Copy the blast for the watch.
    TEXT

    Result = Struct.new(:error, :hits, :is_llm_error, keyword_init: true)

    def self.conduct
      hits = 0
      mutex = Mutex.new
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]
      acceptor = Thread.new do
        loop do
          client = server.accept
          Thread.new do
            mutex.synchronize { hits += 1 }
            sleep 5
            client.close
          rescue IOError
            nil
          end
        end
      rescue IOError
        nil
      end

      configure
      error = nil
      begin
        circuit = RubyLLM.context do |config|
          config.openrouter_api_base = "http://127.0.0.1:#{port}/api/v1"
          config.max_retries = 2
          config.retry_interval = 0.05
          config.retry_interval_randomness = 0.0
          config.retry_backoff_factor = 1
          config.retry_max_interval = 1
          config.request_timeout = 1
        end
        chat = circuit.chat(
          model: Multivitamin::Models::CHAT,
          provider: :openrouter,
          assume_model_exists: true
        )
        chat.with_instructions(INSTRUCTIONS)
        chat.ask(CARD_QUESTION)
      rescue StandardError => raised
        error = raised
      ensure
        server.close
        acceptor.kill
      end

      Result.new(
        error: error,
        hits: hits,
        is_llm_error: error.is_a?(RubyLLM::Error)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = Multivitamin::Models.api_key("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        config.openai_use_system_role = true
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end

    def self.ignore_loopback!
      VCR.configure do |config|
        config.ignore_request { |request| URI(request.uri).host == "127.0.0.1" }
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "horn_retries") do
    PointNoPointRetries::HornRetries.ignore_loopback!
    result = PointNoPointRetries::HornRetries.conduct
  end

  puts "#{result.error.class} hits=#{result.hits}"
end
