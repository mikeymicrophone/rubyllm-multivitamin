# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sounding_pole"

class SoundingPoleTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sounding_pole.yml", __dir__)

  def test_ten_steps_leave_the_spit_mid_round
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sounding_pole") do
      result = TahuyaTenStepBudget::SpitWatch.conduct
    end

    assert_equal 10, result.steps
    refute result.settled
    assert_equal 5, result.marks
    assert_equal 5, result.tool_count
    assert_operator result.resumed_mark, :>, result.marks
    assert_equal :tool, result.roles.last
    joined = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_operator joined.size, :>=, 6
    refute_includes joined.fetch(0), "sounding 1 of 20"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
