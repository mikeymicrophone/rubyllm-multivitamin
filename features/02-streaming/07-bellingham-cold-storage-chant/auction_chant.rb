# frozen_string_literal: true

# Streaming · 07 · Bellingham cold storage chant
#
# Teaches:
# - A long chant runs the block more than once.
# - Each spoken chunk can be written to an IO.
# - The same chunks can be pulled from an Enumerator.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BellinghamAuctionChant
  # The auctioneer at Bellingham Cold Storage chants four lots. The clerk's
  # tape is an IO. The office pulls the same chant from an Enumerator.
  class AuctionChant
    INSTRUCTIONS = <<~TEXT.strip
      You are the auctioneer on the fish dock at Bellingham Cold Storage.
      Chant the four lots in order, one short sentence each.
      Use only the lot sheet.
      Name each lot number, the boat, and the case count.
      Do not invent a price.
    TEXT

    SHEET_QUESTION = <<~TEXT.strip
      Dock auction Wednesday 14 October 2026 at Bellingham Cold Storage.
      Dock office: https://www.portofbellingham.com/
      Lot 14, sockeye halves, 18 cases, F/V Alden.
      Lot 15, pink salmon, 12 cases, F/V Retort.
      Lot 16, coho, 9 cases, F/V Kelp.
      Lot 17, chum, 7 cases, F/V Ledge.
      Chant the four lots for the clerk's tape.
    TEXT

    Result = Struct.new(:speech, :pieces, :tape, :bid_count, keyword_init: true)

    attr_reader :chant

    def self.conduct(tape)
      configure

      board = new
      pieces = board.each_bid(tape).to_a
      Result.new(
        speech: board.chant.content,
        pieces: pieces,
        tape: tape.string,
        bid_count: pieces.size
      )
    end

    def each_bid(tape)
      return enum_for(:each_bid, tape) unless block_given?

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

      @chant = chat.ask(SHEET_QUESTION) do |chunk|
        piece = chunk.content.to_s
        next if piece.empty?

        tape.write(piece)
        yield piece
      end
    end

    def open_chat
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
  require "stringio"

  tape = StringIO.new
  result = nil
  Multivitamin::Cassettes.play(__dir__, "auction_chant") do
    result = BellinghamAuctionChant::AuctionChant.conduct(tape)
  end

  puts result.tape
end
