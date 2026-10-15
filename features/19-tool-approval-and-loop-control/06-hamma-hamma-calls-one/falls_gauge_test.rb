# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "falls_gauge"

class FallsGaugeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/falls_gauge.yml", __dir__)

  def test_one_call_per_turn_still_reads_both_falls
    result = nil
    Multivitamin::Cassettes.play(__dir__, "falls_gauge") do
      result = HammaHammaCallsOne::FallsWatch.conduct
    end

    assert_equal 1, result.first_call_count
    assert_operator result.tool_contents.size, :>=, 1
    joined = result.tool_contents.join("\n")
    assert_includes joined, "2.1"
    assert_includes joined, "5.4"
    assert_includes result.answer, "2.1"
    assert_includes result.answer, "5.4"

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"parallel_tool_calls":false'
    refute_includes request, "2.1 ft"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
