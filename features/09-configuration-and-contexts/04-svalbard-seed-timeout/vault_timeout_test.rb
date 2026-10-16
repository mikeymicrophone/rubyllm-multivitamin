# frozen_string_literal: true

require "minitest/autorun"
require_relative "vault_timeout"

class SvalbardSeedTimeoutTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/vault_timeout.yml", __dir__)

  def test_the_vault_context_timeout_does_not_change_the_global_timeout
    result = nil
    Multivitamin::Cassettes.play(__dir__, "vault_timeout") do
      result = SvalbardSeedTimeout::VaultTimeout.conduct
    end

    assert_includes result.slate, "-18"
    assert_includes result.slate, "SV-180"
    assert_match(/teff/i, result.slate)
    assert_equal SvalbardSeedTimeout::VaultTimeout::VAULT_TIMEOUT, result.vault_timeout
    assert_equal SvalbardSeedTimeout::VaultTimeout::GLOBAL_TIMEOUT, result.global_timeout
    refute_equal result.vault_timeout, result.global_timeout
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
