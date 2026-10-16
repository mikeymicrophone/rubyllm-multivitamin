# frozen_string_literal: true

require "minitest/autorun"
require_relative "farm_log"

class PersistedIbadanSchoolFarmLogTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/farm_log.yml", __dir__)

  def test_the_farm_log_persists_the_brief_and_the_model
    result = nil
    Multivitamin::Cassettes.play(__dir__, "farm_log") do
      result = IbadanSchoolFarmLog::FarmClerk.conduct
    end

    assert result.persisted
    assert_includes result.brief, "Amina"
    assert_includes result.brief, "07:15"
    assert_equal 3, result.entry_count
    assert_equal %i[system user assistant], result.roles
    assert_equal "gpt-4.1-mini", result.model_id
    assert_equal "openai", result.provider
    assert_equal "RubyLLM::ActiveRecord::Model", result.model_class
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
