# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "ball_stock"

class BallStockTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ball_stock.yml", __dir__)

  def test_the_ticket_is_forced_onto_the_ball_tool
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ball_stock") do
      result = MelbourneCricketNet::BallTicket.conduct
    end

    assert_includes result.tool_contents.join("\n"), "14 dozen"
    refute_includes result.tool_contents.join("\n"), "6 inch"
    assert_includes result.answer, "14"
    assert_match(/stump/i, result.answer)
    assert_equal %i[system user assistant tool assistant], result.roles

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_includes bodies.fetch(0), '"name":"ball_stock"'
    assert_includes bodies.fetch(0), '"name":"stump_gauge"'
    assert_includes bodies.fetch(0), '"tool_choice":{"type":"function","name":"ball_stock"}'
    refute_includes bodies.fetch(1), '"tool_choice"'
    refute_includes bodies.fetch(0), "14 dozen"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
