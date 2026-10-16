# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "hearth_sizes"

class RilaHearthSizesTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/hearth_sizes.yml", __dir__)

  def test_square_and_landscape_sizes_are_separate_requests
    result = nil
    Multivitamin::Cassettes.play(__dir__, "hearth_sizes") do
      result = RilaHearthSizes::HearthSizes.conduct
    end

    assert_instance_of RubyLLM::Image, result.square
    assert_instance_of RubyLLM::Image, result.landscape

    bodies = request_bodies
    assert_equal 2, bodies.length
    assert_includes bodies.fetch(0), '"size":"1024x1024"'
    assert_includes bodies.fetch(0), "copper cauldron"
    assert_includes bodies.fetch(1), '"size":"1536x1024"'
    assert_includes bodies.fetch(1), "colonnade"
    refute_includes bodies.fetch(0), "1536x1024"
    refute_includes bodies.fetch(1), "1024x1024"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
