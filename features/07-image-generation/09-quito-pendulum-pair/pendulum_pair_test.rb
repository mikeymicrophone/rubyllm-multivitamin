# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pendulum_pair"

class QuitoPendulumPairTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pendulum_pair.yml", __dir__)

  def test_count_two_returns_an_array_and_usage_stays_on_the_first
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pendulum_pair") do
      result = QuitoPendulumPair::PendulumPair.conduct
    end

    assert_kind_of Array, result.images
    assert_equal 2, result.images.length
    result.images.each { |image| assert_instance_of RubyLLM::Image, image }
    assert_operator result.first_output_tokens, :>, 0
    assert_nil result.second_output_tokens

    request = request_body
    assert_includes request, '"n":2'
    assert_includes request, "16.4"
    refute_includes request, '"n":1'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end
end
