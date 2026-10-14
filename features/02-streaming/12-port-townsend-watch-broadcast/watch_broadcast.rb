# frozen_string_literal: true

# Streaming · 12 · Port Townsend watch broadcast
#
# Teaches:
# - Each spoken chunk can be broadcast to every station that subscribed.
# - The shape is the one a later Rails integration can wrap. This folder
#   stays on plain Ruby.
# - Empty chunks are not broadcast. Each station's tape matches the message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendWatchBroadcast
  # The Point Wilson watch reads a gale for Admiralty Inlet. The slip at
  # Port Townsend and the tender Alden are both listening.
  class WatchChannel
    def initialize
      @subscriptions = []
    end

    def subscribe(station, &listener)
      @subscriptions << [station, listener]
      self
    end

    def broadcast(piece)
      @subscriptions.each { |station, listener| listener.call(station, piece) }
    end
  end

  class GaleBroadcast
    INSTRUCTIONS = <<~TEXT.strip
      You are the watch at Point Wilson Light Station, speaking to the boats listening in.
      Speak the warning in two short sentences.
      Name Admiralty Inlet, the gust of 45 knots, and the tender Alden.
      Use only the warning in the question.
    TEXT

    WARNING_QUESTION = <<~TEXT.strip
      Broadcast Wednesday 14 October 2026 from Point Wilson to the boats on Admiralty Inlet.
      Slip office: https://wsdot.wa.gov/ferries
      Gale warning. Southwest wind 35 knots, gusts 45 knots, through 18:00.
      The foghorn tender Alden is alongside the Port Townsend slip and should hold.
      Small craft stay off the west side of the inlet.
      Speak the broadcast.
    TEXT

    Result = Struct.new(:speech, :pieces, :tapes, :broadcasts, keyword_init: true)

    def self.conduct
      configure

      tapes = Hash.new { |heard, station| heard[station] = +"" }
      channel = WatchChannel.new
      channel.subscribe("Port Townsend slip") { |_station, piece| tapes["Port Townsend slip"] << piece }
      channel.subscribe("tender Alden") { |_station, piece| tapes["tender Alden"] << piece }

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

      pieces = []
      broadcasts = 0
      message = chat.ask(WARNING_QUESTION) do |chunk|
        piece = chunk.content.to_s
        next if piece.empty?

        pieces << piece
        broadcasts += 1
        channel.broadcast(piece)
      end

      Result.new(speech: message.content, pieces: pieces, tapes: tapes, broadcasts: broadcasts)
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "watch_broadcast") do
    result = PortTownsendWatchBroadcast::GaleBroadcast.conduct
  end

  puts result.speech
end
