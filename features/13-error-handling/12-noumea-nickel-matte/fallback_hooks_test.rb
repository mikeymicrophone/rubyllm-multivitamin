# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "fallback_hooks"

class NoumeaNickelMatteFallbackHooksTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/fallback_hooks.yml", __dir__)

  def test_the_hooks_see_the_timeout_then_openai_answers
    result = nil
    Multivitamin::Cassettes.play(__dir__, "fallback_hooks") do
      NoumeaNickelMatte::FallbackHooks.ignore_loopback!
      result = NoumeaNickelMatte::FallbackHooks.conduct
    end

    assert_equal 1, result.hits
    assert_equal 1, result.before.size
    assert_equal Multivitamin::Models::CHAT, result.before.fetch(0)[:from]
    assert_equal Multivitamin::Models::OPENAI_CHAT, result.before.fetch(0)[:to]
    assert_equal "Faraday::TimeoutError", result.before.fetch(0)[:error]
    assert_equal 1, result.before.fetch(0)[:attempt]
    assert_equal true, result.after.fetch(0)[:succeeded]
    assert_nil result.after.fetch(0)[:fallback_error]
    assert_includes result.brief, "2.8"
    assert_match(/south/i, result.brief)
    assert_includes result.model, "gpt-4.1-mini"
    assert_equal %i[system user assistant], result.roles
    assert_equal 1, interactions.length
    assert_includes interactions.fetch(0).dig("request", "uri"), "api.openai.com"
    assert_includes RubyLLM::Fallback::DEFAULT_ERRORS, Faraday::TimeoutError
    refute_match(/127\.0\.0\.1/, RubyLLM.config.openrouter_api_base.to_s)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
