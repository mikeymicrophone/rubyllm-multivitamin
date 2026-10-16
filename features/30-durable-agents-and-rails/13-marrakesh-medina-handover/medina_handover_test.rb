# frozen_string_literal: true

require "minitest/autorun"
require_relative "medina_handover"

class MarrakeshMedinaHandoverTest < Minitest::Test
  def test_medina_handover_resumes_within_budget
    result = Multivitamin::Cassettes.play(__dir__, "medina_handover") { MarrakeshMedinaHandover.conduct }

    assert_equal 1, result.fetch(:first_jobs)
    assert_equal 1, result.fetch(:parking_jobs)
    assert result.fetch(:budget_exhausted)
    assert_equal 0, result.fetch(:queued_after_cap)
    assert_equal 2, result.fetch(:resumed_jobs)
    assert result.fetch(:parked)
    assert_equal 0, result.fetch(:passes_before)
    assert_equal 1, result.fetch(:passes_after)
    assert result.fetch(:complete)
    assert_equal 1, result.fetch(:system_rows)
    assert_includes result.fetch(:handover), "Amina"
    assert_includes result.fetch(:handover), "Bab Doukkala"
    assert_includes result.fetch(:handover), "06:45"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/medina_handover.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
