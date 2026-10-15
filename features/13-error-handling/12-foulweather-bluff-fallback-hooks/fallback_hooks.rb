# frozen_string_literal: true

# Error handling · 12 · Foulweather Bluff fallback hooks
#
# Teaches:
# - Faraday::TimeoutError is in Fallback::DEFAULT_ERRORS.
# - max_retries is 0 so Faraday does not triple the dead-circuit wait.
# - before_fallback sees fallback.from, fallback.to, and fallback.error.
# - after_fallback sees succeeded? once OpenAI answers.

require "logger"
require "ruby_llm"
require "socket"
require "uri"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FoulweatherBluffFallbackHooks
  # The current desk under Foulweather Bluff, at the mouth of Hood Canal,
  # first calls a dead circuit. with_fallbacks then takes the brief to
  # gpt-4.1-mini. The hooks log the jump.
  class FallbackHooks
    INSTRUCTIONS = <<~TEXT.strip
      You are the current clerk under Foulweather Bluff, at the mouth of Hood Canal.
      Answer in two short sentences.
      Use only the current card in the question.
      Name 2.8 knots and the flood.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Current card posted under Foulweather Bluff, Thursday 15 October 2026.
      Preserve notes: https://www.dnr.wa.gov/FoulweatherBluff.
      Flood 2.8 knots at 11:10, setting south into Hood Canal.
      Ebb 1.9 knots at 17:40.
      What is the flood, and which way does it set?
    TEXT

    Result = Struct.new(
      :brief,
      :hits,
      :before,
      :after,
      :roles,
      :model,
      keyword_init: true
    )

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
            sleep 6
            client.close
          rescue IOError
            nil
          end
        end
      rescue IOError
        nil
      end

      configure
      spare = RubyLLM.models.find(Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      before = []
      after = []
      brief = nil
      roles = nil
      model = nil

      begin
        circuit = RubyLLM.context do |config|
          config.openrouter_api_base = "http://127.0.0.1:#{port}/api/v1"
          config.max_retries = 0
          config.request_timeout = 2
        end
        chat = circuit.chat(
          model: Multivitamin::Models::CHAT,
          provider: :openrouter,
          assume_model_exists: true
        )
        chat.with_instructions(INSTRUCTIONS)
        chat.with_temperature(0.2)
        chat.with_fallbacks(spare)
        chat.before_fallback do |fallback|
          before << {
            from: fallback.from.id,
            to: fallback.to.id,
            error: fallback.error.class.name,
            attempt: fallback.attempt
          }
        end
        chat.after_fallback do |fallback|
          after << {
            succeeded: fallback.succeeded?,
            to: fallback.to.id,
            fallback_error: fallback.fallback_error&.class&.name
          }
        end

        message = chat.ask(CARD_QUESTION)
        brief = message.content
        roles = chat.messages.map(&:role)
        model = message.model
      ensure
        server.close
        acceptor.kill
      end

      Result.new(
        brief: brief,
        hits: hits,
        before: before,
        after: after,
        roles: roles,
        model: model
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = Multivitamin::Models.api_key("OPENROUTER_API_KEY")
        config.openai_api_key = Multivitamin::Models.api_key("OPENAI_API_KEY")
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
  Multivitamin::Cassettes.play(__dir__, "fallback_hooks") do
    FoulweatherBluffFallbackHooks::FallbackHooks.ignore_loopback!
    result = FoulweatherBluffFallbackHooks::FallbackHooks.conduct
  end

  puts result.brief
  puts result.before.inspect
  puts result.after.inspect
end
