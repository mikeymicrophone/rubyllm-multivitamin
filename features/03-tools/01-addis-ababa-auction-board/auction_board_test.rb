# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "auction_board"

class AuctionBoardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/auction_board.yml", __dir__)

  def test_the_board_is_a_string_and_the_floor_hears_the_times
    result = nil
    Multivitamin::Cassettes.play(__dir__, "auction_board") do
      result = AddisAbabaAuctionBoard::AuctionWindow.conduct
    end

    assert_equal AddisAbabaAuctionBoard::PostedLotBoard::BOARD, result.tool_content
    refute_includes result.tool_content, "{"
    assert_includes result.answer, "10:46"
    assert_includes result.answer, "08:57"
    assert_includes result.answer, "Halima"
    assert_includes result.answer, "Tadesse"
    assert_equal %i[system user assistant tool assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"gpt-4.1-mini"'
    assert_includes request, '"name":"posted_lot_board"'
    assert_includes request, '"tool_choice":{"type":"function","name":"posted_lot_board"}'
    assert_includes request, '"stream":false'
    assert_includes request, "reasoning.encrypted_content"
    refute_includes request, '"reasoning":{"enabled":false}'
    refute_includes request, "10:46"
    refute_includes request, "08:57"
  end

  def test_thinking_off_raises_before_a_request
    Multivitamin::Cassettes.prepare_key!
    AddisAbabaAuctionBoard::AuctionWindow.configure
    chat = AddisAbabaAuctionBoard::AuctionWindow.open_chat
    chat.with_thinking(false)

    error = assert_raises(ArgumentError) { chat.ask("Read the posted chalkboard.") }

    assert_match(/no off control/, error.message)
    assert_match(/gpt-4.1-mini/, error.message)
  end

  def test_the_tool_name_and_empty_schema_are_declared_on_the_class
    tool = AddisAbabaAuctionBoard::PostedLotBoard.new

    assert_equal "posted_lot_board", tool.name
    assert_equal AddisAbabaAuctionBoard::PostedLotBoard::BOARD, tool.execute
    assert_equal [], tool.parameters_schema.fetch("required")
    assert_equal({}, tool.parameters_schema.fetch("properties"))
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
