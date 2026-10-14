# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "morning_cook"

class MorningCookTest < Minitest::Test
  def test_the_recap_uses_the_cook_and_the_correction
    result = nil
    Multivitamin::Cassettes.play(__dir__, "morning_cook") do
      result = AnacortesRetortLog::MorningCook.conduct
    end

    assert_includes result.log_line, "240"
    assert_includes result.log_line, "3"
    assert_includes result.correction, "242"
    assert_includes result.recap, "242"
    # The model separates "basket" and "3" with U+202F, not a normal space.
    assert_includes result.recap, "basket\u202f3"
    assert_match(/basket[[:space:]]3/i, result.recap)
    assert_includes result.recap, "75"

    assert_equal %i[system user assistant user assistant user assistant], result.roles
    assert_equal :stop, result.log_finish
    assert_equal :stop, result.recap_finish
    assert_operator result.recap_input_tokens, :>, result.log_input_tokens
  end

  def test_the_next_request_carries_the_previous_reasoning
    cassette = YAML.load_file(File.expand_path("cassettes/morning_cook.yml", __dir__))
    interactions = cassette.fetch("http_interactions")
    first_request = interactions[0].dig("request", "body", "string")
    second_request = interactions[1].dig("request", "body", "string")

    refute_includes first_request, "reasoning_details"
    assert_includes second_request, "reasoning_details"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/morning_cook.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
