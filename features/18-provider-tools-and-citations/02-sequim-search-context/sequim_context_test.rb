# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sequim_context"

class ProviderToolsSequimSearchContextTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sequim_context.yml", __dir__)

  def test_filters_are_rejected_and_a_low_context_search_cites
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sequim_context") do
      result = SequimSearchContext::SequimContext.conduct
    end

    assert_equal "RubyLLM::BadRequestError", result.filter_error
    assert_match(/filters/i, result.filter_message)

    assert_match(/Sequim/i, result.brief)
    assert_match(/Alden/i, result.brief)
    assert result.citation_urls.any?
    assert_operator result.search_requests, :>=, 1
    assert_operator result.cost, :>, 0

    filter_request, context_request = request_bodies
    assert_includes filter_request, '"filters"'
    assert_includes filter_request, "tidesandcurrents.noaa.gov"
    assert_equal 400, statuses.fetch(0)
    assert_includes context_request, '"search_context_size":"low"'
    assert_includes context_request, '"type":"web_search"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |interaction| interaction.dig("request", "body", "string").to_s }
  end

  def statuses
    interactions.map { |interaction| interaction.dig("response", "status", "code") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
