# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "morning_bale"

class MorningBaleTest < Minitest::Test
  def test_the_recap_uses_the_receiving_and_the_correction
    result = nil
    Multivitamin::Cassettes.play(__dir__, "morning_bale") do
      result = LagosAnkaraBale::MorningBale.conduct
    end

    assert_includes result.log_line, "240"
    assert_includes result.log_line, "3"
    assert_includes result.correction, "242"
    assert_includes result.recap, "242"
    assert_match(/bale.*\b3\b/i, result.recap)
    assert_includes result.recap, "75"

    assert_equal %i[system user assistant user assistant user assistant], result.roles
    assert_equal :stop, result.log_finish
    assert_equal :stop, result.recap_finish
    assert_operator result.recap_input_tokens, :>, result.log_input_tokens
  end

  def test_the_next_request_carries_the_previous_log_line
    cassette = YAML.load_file(File.expand_path("cassettes/morning_bale.yml", __dir__))
    interactions = cassette.fetch("http_interactions")
    first_request = interactions[0].dig("request", "body", "string")
    second_request = interactions[1].dig("request", "body", "string")

    refute_includes first_request, "242 yards"
    assert_includes second_request, "240 yards"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/morning_bale.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
