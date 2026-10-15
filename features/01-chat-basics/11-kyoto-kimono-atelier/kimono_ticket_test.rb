# frozen_string_literal: true

require "minitest/autorun"
require_relative "kimono_ticket"

class KimonoTicketTest < Minitest::Test
  def test_two_personas_and_a_transcript_that_grows
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kimono_ticket") do
      result = KyotoKimonoAtelier::KimonoTicket.conduct
    end

    assert_includes result.first_stitch, "36"
    assert_match(/collar/i, result.first_stitch)
    assert_includes result.after_the_hail, "48"
    assert_includes result.after_the_hail, "36"
    assert_includes result.after_the_hail, "9"
    assert_match(/KM.214/, result.bride)
    assert_match(/collar/i, result.bride)

    assert_equal [3, 5], result.dresser_lengths
    assert_equal 3, result.bride_length
    assert_equal %i[system user assistant user assistant], result.dresser_roles
    assert_equal %i[system user assistant], result.bride_roles

    assert_includes result.dresser_instructions, "Hanae"
    assert_includes result.bride_instructions, "Aiko"
    refute_equal result.dresser_instructions, result.bride_instructions
    assert result.hem_hail_on_the_dresser_chat
    refute result.hem_hail_on_the_bride_chat
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/kimono_ticket.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
