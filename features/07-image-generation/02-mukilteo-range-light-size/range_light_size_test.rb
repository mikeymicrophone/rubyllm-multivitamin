# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "range_light_size"

class MukilteoRangeLightSizeTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/range_light_size.yml", __dir__)

  def test_the_request_names_the_smallest_supported_size
    result = nil
    Multivitamin::Cassettes.play(__dir__, "range_light_size") do
      result = MukilteoRangeLightSize::RangeLightSize.conduct
    end

    assert_instance_of RubyLLM::Image, result.image
    assert_equal "1024x1024", result.size_on_wire
    request = request_body
    assert_includes request, '"size":"1024x1024"'
    refute_includes request, "256x256"
    refute_includes request, "512x512"
    assert_includes request, "Mukilteo"
    assert_includes request, '"quality":"low"'
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
