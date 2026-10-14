# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "posted_board"

class PostedBoardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/posted_board.yml", __dir__)

  def test_the_board_is_a_string_and_the_watch_hears_the_times
    result = nil
    Multivitamin::Cassettes.play(__dir__, "posted_board") do
      result = PointWilsonTideWindow::TideWindow.conduct
    end

    assert_equal PointWilsonTideWindow::PostedTideBoard::BOARD, result.tool_content
    refute_includes result.tool_content, "{"
    assert_includes result.answer, "10:46"
    assert_includes result.answer, "08:57"
    assert_includes result.answer, "Alden"
    assert_includes result.answer, "Retort"
    assert_equal %i[system user assistant tool assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"model":"gpt-4.1-mini"'
    assert_includes request, '"name":"posted_tide_board"'
    assert_includes request, '"tool_choice":{"type":"function","name":"posted_tide_board"}'
    assert_includes request, '"stream":false'
    assert_includes request, "reasoning.encrypted_content"
    refute_includes request, '"reasoning":{"enabled":false}'
    refute_includes request, "10:46"
    refute_includes request, "08:57"
  end

  def test_thinking_off_raises_before_a_request
    Multivitamin::Cassettes.prepare_key!
    PointWilsonTideWindow::TideWindow.configure
    chat = PointWilsonTideWindow::TideWindow.open_chat
    chat.with_thinking(false)

    error = assert_raises(ArgumentError) { chat.ask("Read the posted board.") }

    assert_match(/no off control/, error.message)
    assert_match(/gpt-4.1-mini/, error.message)
  end

  def test_the_tool_name_and_empty_schema_are_declared_on_the_class
    tool = PointWilsonTideWindow::PostedTideBoard.new

    assert_equal "posted_tide_board", tool.name
    assert_equal PointWilsonTideWindow::PostedTideBoard::BOARD, tool.execute
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
