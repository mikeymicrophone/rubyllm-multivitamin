# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "assume_clerk"

class CommencementBayAssumeClerkTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/assume_clerk.yml", __dir__)

  def test_assume_requires_a_provider_and_the_grain_clerk_still_asks
    result = nil
    Multivitamin::Cassettes.play(__dir__, "assume_clerk") do
      result = CommencementBayGrain::AssumeClerk.conduct
    end

    assert_equal "ArgumentError", result.missing_provider_error
    assert_includes result.missing_provider_message, "Provider must be specified"

    assert_equal CommencementBayGrain::AssumeClerk::UNLISTED, result.unlisted_id
    assert_equal "openai", result.unlisted_provider
    assert_equal %w[function_calling streaming vision structured_output], result.unlisted_capabilities
    assert_equal "Assuming model exists, capabilities may not be accurate", result.unlisted_warning
    assert result.unlisted_function_calling
    refute result.unlisted_reasoning
    assert_nil result.unlisted_window

    assert_equal Multivitamin::Models::OPENAI_CHAT, result.listed_id
    assert_nil result.listed_warning
    refute_equal result.unlisted_capabilities, result.listed_capabilities
    assert_equal 1_047_576, result.listed_window
    assert_includes result.listed_capabilities, "function_calling"
    assert_includes result.listed_capabilities, "vision"
    refute_includes result.listed_capabilities, "streaming"

    assert_match(/\A\s*Yes\b/i, result.alongside.to_s)
    assert_includes result.alongside, "Magnolia Stem"
    assert_includes result.alongside, "34"
    assert_includes result.alongside, "32"
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, CommencementBayGrain::AssumeClerk::UNLISTED
  end

  def test_cassette_asks_the_listed_openai_slug
    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end

    assert_equal 1, bodies.size
    assert_includes bodies.fetch(0), Multivitamin::Models::OPENAI_CHAT
    assert_includes bodies.fetch(0), "Magnolia Stem"
  end
end
