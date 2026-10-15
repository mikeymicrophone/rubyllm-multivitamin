# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "search_desk"

class ProviderToolsTerminationPointSearchDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/search_desk.yml", __dir__)

  def test_the_desk_hails_noaa_then_interpolates_the_ledge
    result = nil
    Multivitamin::Cassettes.play(__dir__, "search_desk") do
      result = TerminationPointSearchDesk::SearchDesk.conduct
    end

    assert_equal(
      [{ name: :web_search, options: {} }, { name: :code_execution, options: {} }],
      result.declared_tools
    )
    assert_match(/Termination Point/i, result.hail)
    assert_match(/Alden/i, result.hail)
    assert result.citation_urls.any?
    assert_includes result.hail_calls, "web_search_call"

    assert_match(/Termination Point/i, result.height)
    assert_match(/Alden/i, result.height)
    assert_match(/5\.99/, result.height)
    assert_includes result.height_calls, "code_interpreter_call"
    assert_equal %i[system user assistant user assistant], result.roles
    assert_operator result.cost, :>, 0

    first, second = request_bodies
    assert_includes first, '"type":"web_search"'
    assert_includes first, '"type":"code_interpreter"'
    assert_includes second, '"type":"web_search"'
    assert_includes second, '"type":"code_interpreter"'
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
