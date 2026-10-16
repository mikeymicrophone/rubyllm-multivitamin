# frozen_string_literal: true

require "minitest/autorun"
require_relative "frevo_job"

class RecifeFrevoAtelierJobTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/frevo_job.yml", __dir__)

  def test_the_job_clears_needs_review_on_a_clean_square
    result = nil
    Multivitamin::Cassettes.play(__dir__, "frevo_job") do
      result = RecifeFrevoAtelier::ReviewPhotoJob.conduct
    end

    refute result.flagged
    refute result.needs_review
    assert result.persisted
    assert_includes result.atelier, "Frevo"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
