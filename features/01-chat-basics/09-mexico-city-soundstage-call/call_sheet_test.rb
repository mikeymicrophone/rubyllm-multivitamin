# frozen_string_literal: true

require "minitest/autorun"
require_relative "call_sheet"

class CallSheetTest < Minitest::Test
  def test_the_reused_chat_knows_the_patio_and_the_fresh_chat_does_not
    result = nil
    Multivitamin::Cassettes.play(__dir__, "call_sheet") do
      result = MexicoCitySoundstage::CallSheet.conduct
    end

    assert_includes result.monzon, "09:15"
    assert_includes result.monzon, "Monzón"
    assert_includes result.patio_on_the_same_chat, "15:05"
    assert_includes result.patio_on_the_same_chat, "Patio"

    assert_includes result.patio_on_a_fresh_chat, "The call sheet was not handed over."
    refute_includes result.patio_on_a_fresh_chat, "15:05"

    assert_equal %i[system user assistant user assistant], result.reused_roles
    assert_equal %i[system user assistant], result.fresh_roles
    assert_equal "And the Patio de los Naranjos unit?", result.fresh_user_text
    assert result.reused_still_has_sheet
    refute_includes result.fresh_user_text, "Monzón del Palacio"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/call_sheet.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
