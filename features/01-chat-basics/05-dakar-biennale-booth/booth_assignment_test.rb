# frozen_string_literal: true

require "minitest/autorun"
require_relative "booth_assignment"

class BoothAssignmentTest < Minitest::Test
  def test_the_reply_names_one_booth_and_the_transcript_keeps_the_board
    result = nil
    Multivitamin::Cassettes.play(__dir__, "booth_assignment") do
      result = DakarBiennaleBooths::BoothAssignment.conduct
    end

    assert_includes result.assignment, "G-14"
    assert_includes result.assignment, "Chioma"
    assert_equal %i[system user assistant], result.roles
    assert_equal 3, result.message_count

    assert_includes result.user_board, "G-14"
    assert_includes result.user_board, "H-2"
    assert_includes result.user_board, "Mateo Ruiz"
    assert_includes result.user_board, "Yuki Tanaka"
    assert_includes result.user_board, "J-7"
    assert_includes result.user_board, "biennaledakar.org"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/booth_assignment.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
