# frozen_string_literal: true

require "minitest/autorun"
require_relative "seed_vault_task"

class SvalbardSeedVaultTaskTest < Minitest::Test
  def test_seed_vault_task_survives_rehydration
    result = Multivitamin::Cassettes.play(__dir__, "seed_vault_task") { SvalbardSeedVaultTask.conduct }

    assert_equal "vault-B12", result.fetch(:task_id)
    refute_empty result.fetch(:saved_state)
    assert_equal 2, result.fetch(:jobs)
    assert result.fetch(:complete)
    assert_equal 1, result.fetch(:results)
    assert_includes result.fetch(:brief), "24 crates"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/seed_vault_task.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
