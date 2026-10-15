# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "horn_prefix"

class CapeDisappointmentMcpOnlyPrefixTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/horn_prefix.yml", __dir__)

  def test_only_except_and_prefix_shape_the_names_the_model_sees
    result = nil
    Multivitamin::Cassettes.play(__dir__, "horn_prefix") do
      result = CapeDisappointmentOnlyPrefix::HornPrefix.conduct
    end

    assert_equal %w[cape_posted_horn_card cape_posted_tide_board].sort, result.tool_names.sort
    refute_includes result.tool_names, "silence_horn"
    refute_includes result.tool_names, "posted_horn_card"
    assert_equal "Cape Disappointment horn is running. Blast 3 seconds, silent 27 seconds.", result.tool_content
    assert_includes result.answer, "Peacock"
    assert_includes result.answer, "3 seconds"
    assert_equal %i[system user assistant tool assistant], result.roles

    request = request_bodies.fetch(0)
    assert_includes request, '"name":"cape_posted_horn_card"'
    refute_includes request, "silence_horn"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
