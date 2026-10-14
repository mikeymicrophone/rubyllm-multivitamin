# frozen_string_literal: true

require "minitest/autorun"
require_relative "slip_assignment"

class SlipAssignmentTest < Minitest::Test
  def test_the_reply_names_one_berth_and_the_transcript_keeps_the_board
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_assignment") do
      result = FridayHarborBerths::SlipAssignment.conduct
    end

    assert_includes result.assignment, "G-14"
    assert_includes result.assignment, "Alden"
    assert_equal %i[system user assistant], result.roles
    assert_equal 3, result.message_count

    assert_includes result.user_board, "G-14"
    assert_includes result.user_board, "H-2"
    assert_includes result.user_board, "Retort"
    assert_includes result.user_board, "Cape Flattery"
    assert_includes result.user_board, "J-7"
    assert_includes result.user_board, "portfridayharbor.org"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/slip_assignment.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
