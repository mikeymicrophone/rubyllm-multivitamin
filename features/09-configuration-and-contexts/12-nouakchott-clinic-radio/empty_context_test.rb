# frozen_string_literal: true

require "minitest/autorun"
require_relative "empty_context"

class NouakchottClinicRadioTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/empty_context.yml", __dir__)

  def test_the_empty_context_raises_before_http_and_the_working_radio_still_asks
    result = nil
    Multivitamin::Cassettes.play(__dir__, "empty_context") do
      result = NouakchottClinicRadio::EmptyContext.conduct
    end

    assert_equal RubyLLM::ConfigurationError, result.empty_error_class
    refute result.empty_is_llm_error
    assert_match(/not configured/i, result.empty_error_message)
    assert_includes result.ledger, "11.8"
    assert_equal 1, yaml_interactions.length
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def yaml_interactions
    require "yaml"
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
