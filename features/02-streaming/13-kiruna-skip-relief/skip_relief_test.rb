# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "skip_relief"

class SkipReliefTest < Minitest::Test
  def test_the_relief_reads_the_card_and_then_stops_the_speech
    result = nil
    Multivitamin::Cassettes.play(__dir__, "skip_relief") do
      result = KirunaSkipRelief::SkipRelief.conduct
    end

    assert_instance_of RubyLLM::CancelledError, result.error
    refute_kind_of RubyLLM::Error, result.error
    assert_equal 2, result.spoken.size
    assert_equal %i[system user assistant tool], result.roles

    assert_includes result.tool_content, "2.5"
    assert_includes result.tool_content, "92"
    assert_kind_of Hash, result.tool_arguments
    assert_includes result.tool_arguments.keys.map(&:to_s), "mine"

    assert result.argument_fragments.any? { |_name, arguments| arguments.is_a?(String) }
    assert result.argument_fragments.any? { |name, arguments| arguments == "" && name }
    joined = result.argument_fragments.map { |_name, arguments| arguments.to_s }.join
    assert_equal result.tool_arguments, JSON.parse(joined)

    cassette = YAML.load_file(File.expand_path("cassettes/skip_relief.yml", __dir__))
    first_request = cassette.dig("http_interactions", 0, "request", "body", "string")
    assert_includes first_request, "posted_skip_card"
    assert_includes first_request, '"stream":true'
    refute_includes first_request, "2.5"
    refute_includes first_request, "92"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/skip_relief.yml", __dir__))

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
