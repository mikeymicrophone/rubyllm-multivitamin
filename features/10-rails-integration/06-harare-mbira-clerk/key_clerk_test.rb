# frozen_string_literal: true

require "minitest/autorun"
require_relative "key_clerk"

class PersistedHarareMbiraClerkTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/key_clerk.yml", __dir__)

  def test_the_key_log_keeps_two_system_rows
    result = nil
    Multivitamin::Cassettes.play(__dir__, "key_clerk") do
      result = HarareMbiraClerk::KeyClerk.conduct
    end

    assert_includes result.brief, "22"
    assert_equal 2, result.system_count
    assert_equal 2, result.reloaded_system_count
    assert_includes result.system_texts.fetch(0), "Mbare"
    assert_includes result.system_texts.fetch(1), "18 grams"
    assert_equal %i[system system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
