# frozen_string_literal: true

require "minitest/autorun"
require_relative "stitch_tickets"

class PersistedLucknowChikanTicketsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/stitch_tickets.yml", __dir__)

  def test_the_stitch_ticket_is_not_the_model_transcript
    result = nil
    Multivitamin::Cassettes.play(__dir__, "stitch_tickets") do
      result = LucknowChikanTickets::AtelierClerk.conduct
    end

    assert_includes result.brief, "18"
    assert_match(/#?21/, result.brief)
    assert_equal %i[system user assistant], result.llm_roles
    assert_equal 3, result.llm_count
    assert_equal 1, result.ticket_count
    assert_equal result.brief, result.ticket_note
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
