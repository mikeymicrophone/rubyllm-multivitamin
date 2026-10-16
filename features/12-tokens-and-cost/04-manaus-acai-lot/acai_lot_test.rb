# frozen_string_literal: true

require "minitest/autorun"
require_relative "acai_lot"

class ManausAcaiLotHailTokensTest < Minitest::Test
  def test_the_long_lot_card_reports_more_input_tokens_than_the_hail
    result = nil
    Multivitamin::Cassettes.play(__dir__, "acai_lot") do
      result = ManausAcaiLot::AcaiLot.conduct
    end

    assert_match(/AMZ[-‑–]441/, result.lot_brief)
    assert_match(/\b18\b/, result.lot_brief)
    assert_match(/AMZ[-‑–]441/, result.hail_brief)
    assert_operator result.lot_input, :>, result.hail_input
    assert_operator result.hail_input, :>, 0
    assert_operator result.lot_output, :>, 0
    assert_operator result.hail_output, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/acai_lot.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
