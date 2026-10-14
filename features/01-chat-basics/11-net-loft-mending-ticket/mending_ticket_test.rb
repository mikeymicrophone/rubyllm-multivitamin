# frozen_string_literal: true

require "minitest/autorun"
require_relative "mending_ticket"

class MendingTicketTest < Minitest::Test
  def test_two_personas_and_a_transcript_that_grows
    result = nil
    Multivitamin::Cassettes.play(__dir__, "mending_ticket") do
      result = AnacortesNetLoft::MendingTicket.conduct
    end

    assert_includes result.first_mend, "36"
    assert_match(/cork/i, result.first_mend)
    assert_includes result.after_the_hail, "48"
    assert_includes result.after_the_hail, "36"
    assert_includes result.after_the_hail, "9"
    assert_match(/NL.214/, result.skipper)
    assert_match(/cork/i, result.skipper)

    assert_equal [3, 5], result.loft_lengths
    assert_equal 3, result.skipper_length
    assert_equal %i[system user assistant user assistant], result.loft_roles
    assert_equal %i[system user assistant], result.skipper_roles

    assert_includes result.loft_instructions, "Hattie"
    assert_includes result.skipper_instructions, "Calder"
    refute_equal result.loft_instructions, result.skipper_instructions
    assert result.belly_hail_on_the_loft_chat
    refute result.belly_hail_on_the_skipper_chat
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/mending_ticket.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
