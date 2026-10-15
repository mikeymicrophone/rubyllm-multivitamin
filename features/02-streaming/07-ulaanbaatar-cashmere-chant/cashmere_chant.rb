# frozen_string_literal: true

# Streaming · 07 · Ulaanbaatar cashmere chant
#
# Teaches:
# - A long chant runs the block more than once.
# - Each spoken chunk can be written to an IO.
# - The same chunks can be pulled from an Enumerator.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module UlaanbaatarCashmereChant
  # The auctioneer at the Gobi cashmere hall in Ulaanbaatar chants four
  # lots. The clerk's tape is an IO. The office pulls the same chant from
  # an Enumerator.
  class CashmereChant
    INSTRUCTIONS = <<~TEXT.strip
      You are the auctioneer in the Gobi cashmere hall in Ulaanbaatar.
      Chant the four lots in order, one short sentence each.
      Use only the lot sheet.
      Name each lot number, the herder, and the kilogram count.
      Do not invent a price.
    TEXT

    SHEET_QUESTION = <<~TEXT.strip
      Cashmere auction Wednesday 14 October 2026 at the Gobi hall, Ulaanbaatar.
      Hall notes: https://www.gobi.mn/
      Lot 14, white combed, 18 kg, herder Altai.
      Lot 15, brown combed, 12 kg, herder Khan.
      Lot 16, grey combed, 9 kg, herder Steppe.
      Lot 17, camel down, 7 kg, herder Ger.
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
      Multivitamin::Models.quiet_thinking(chat, provider: :openrouter)

      @chant = chat.ask(SHEET_QUESTION) do |chunk|
        piece = chunk.content.to_s
        next if piece.empty?

        tape.write(piece)
        yield piece
      end
    end

    def open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "cashmere_chant") do
    result = UlaanbaatarCashmereChant::CashmereChant.conduct(tape)
  end

  puts result.tape
end
