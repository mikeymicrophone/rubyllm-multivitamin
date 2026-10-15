# frozen_string_literal: true

require "json"
require "minitest/autorun"
require_relative "blast_card"

class AgentCapeDisappointmentBlastSchemaTest < Minitest::Test
  def test_the_inline_schema_fills_the_posted_horn_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "blast_card") do
      result = CapeDisappointmentBlastCard::BlastCard.conduct
    end

    parsed = result.parsed
    assert_kind_of Hash, parsed
    assert_equal parsed, JSON.parse(result.content)
    assert_match(/Cape Disappointment/i, parsed.fetch("station"))
    assert_equal 3, parsed.fetch("blast_seconds")
    assert_equal 27, parsed.fetch("gap_seconds")
    assert_equal 90, parsed.fetch("compressor_psi")
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/blast_card.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
