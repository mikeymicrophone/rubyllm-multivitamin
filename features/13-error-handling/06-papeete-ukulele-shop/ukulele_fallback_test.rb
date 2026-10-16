# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "ukulele_fallback"

class PapeeteUkuleleFallbackTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ukulele_fallback.yml", __dir__)

  def test_default_fallbacks_skip_a_400_and_on_reaches_openai
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ukulele_fallback") do
      result = PapeeteUkuleleShop::UkuleleFallback.conduct
    end

    assert_instance_of RubyLLM::BadRequestError, result.default_error
    assert_equal 400, result.default_status
    assert_includes result.default_error.message, PapeeteUkuleleShop::UkuleleFallback::UNLISTED
    assert_includes result.rescued, "8"
    assert_match(/east/i, result.rescued)
    assert_includes result.fallback_model, "gpt-4.1-mini"
    assert_equal %i[system user assistant], result.roles

    statuses = interactions.map { |hit| hit.dig("response", "status", "code") }
    assert_equal [400, 400, 200], statuses
    assert_includes interactions.fetch(2).dig("request", "uri"), "api.openai.com"
    refute_includes RubyLLM::Fallback::DEFAULT_ERRORS, RubyLLM::BadRequestError
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
