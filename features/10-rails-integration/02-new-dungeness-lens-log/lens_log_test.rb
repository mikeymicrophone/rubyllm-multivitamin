# frozen_string_literal: true

require "minitest/autorun"
require_relative "lens_log"

class PersistedNewDungenessLensLogTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lens_log.yml", __dir__)

  def test_the_lens_log_keeps_roles_after_a_reload
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lens_log") do
      result = NewDungenessLensLog::LensKeeper.conduct
    end

    assert_includes result.brief, "3"
    assert_match(/24/, result.brief)
    assert_equal %i[system user user assistant], result.roles
    assert_equal result.roles, result.reloaded_roles
    assert_equal result.assistant_content, result.reloaded_drawer
    assert_includes result.reloaded_drawer, "24"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
