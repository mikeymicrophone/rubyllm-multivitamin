# frozen_string_literal: true

require "minitest/autorun"
require_relative "spool_log"

class PersistedVaranasiZariSpoolLogTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/spool_log.yml", __dir__)

  def test_the_spool_log_keeps_roles_after_a_reload
    result = nil
    Multivitamin::Cassettes.play(__dir__, "spool_log") do
      result = VaranasiZariSpoolLog::SpoolKeeper.conduct
    end

    assert_includes result.brief, "3"
    assert_match(/24/, result.brief)
    assert_equal %i[system user user assistant], result.roles
    assert_equal result.roles, result.reloaded_roles
    assert_equal result.assistant_content, result.reloaded_rack
    assert_includes result.reloaded_rack, "24"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
