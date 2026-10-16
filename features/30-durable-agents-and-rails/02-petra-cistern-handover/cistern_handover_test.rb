# frozen_string_literal: true

require "minitest/autorun"
require_relative "cistern_handover"

class PetraCisternHandoverTest < Minitest::Test
  def test_cistern_history_resumes_by_id
    result = Multivitamin::Cassettes.play(__dir__, "cistern_handover") { PetraCisternHandover.conduct }

    assert_includes result.fetch(:opening), "Salma"
    assert_includes result.fetch(:opening), "840"
    assert_includes result.fetch(:follow_up), "Siq inlet"
    assert_equal 1, result.fetch(:system_rows)
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/cistern_handover.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
