# frozen_string_literal: true

require "minitest/autorun"
require_relative "pilot_slug"

class PersistedNeahBayPilotSlugTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pilot_slug.yml", __dir__)

  def test_assume_model_exists_saves_the_registry_row
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pilot_slug") do
      result = NeahBayPilotSlug::PilotClerk.conduct
    end

    assert_equal Multivitamin::Models::CHAT, result.assumed_model_id
    assert_equal "openrouter", result.assumed_provider
    assert_equal "RubyLLM::ActiveRecord::Model", result.assumed_class
    refute result.has_macro
    assert_equal "gpt-4.1-mini", result.asked_model_id
    assert_includes result.brief, "9"
    assert_match(/Kulshan/i, result.brief)
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
