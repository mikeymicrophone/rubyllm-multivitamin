# frozen_string_literal: true

require "minitest/autorun"
require_relative "passage_preference"

class ColvosPassagePreferenceTest < Minitest::Test
  def test_bare_id_prefers_openai_and_provider_pins_the_other_copies
    result = nil
    Multivitamin::Cassettes.play(__dir__, "passage_preference") do
      result = ColvosPassageFerry::ProviderPreference.conduct
    end

    assert_equal "gpt-4.1-mini", result.bare_id
    assert_equal "openai", result.bare_provider
    assert_equal "gpt-4.1-mini", result.openai_id
    assert_equal "openai", result.openai_provider
    assert_equal "gpt-4.1-mini", result.azure_id
    assert_equal "azure", result.azure_provider
    assert_equal "openai/gpt-4.1-mini", result.openrouter_id
    assert_equal "openrouter", result.openrouter_provider
    assert_includes result.carriers, "openai"
    assert_includes result.carriers, "azure"
    refute_includes result.carriers, "openrouter"
  end
end
