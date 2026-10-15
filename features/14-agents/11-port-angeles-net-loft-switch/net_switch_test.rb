# frozen_string_literal: true

require "minitest/autorun"
require_relative "net_switch"

class AgentPortAngelesNetSwitchTest < Minitest::Test
  def test_with_model_keeps_the_twine_ticket
    result = nil
    Multivitamin::Cassettes.play(__dir__, "net_switch") do
      result = PortAngelesNetLoftSwitch::TwineTicket.conduct
    end

    assert_match(/spool 14/i, result.opening)
    assert_match(/3-strand/i, result.opening)
    assert_includes result.follow_up, "1200"
    assert result.first_user_still_present
    assert_includes result.opening_model, Multivitamin::Models::OPENAI_CHAT
    assert_includes result.follow_up_model, Multivitamin::Models::OPENAI_CHAT_SWITCH
    assert_equal Multivitamin::Models::OPENAI_CHAT_SWITCH, result.switched_chat_model
    refute_equal result.opening_model, result.follow_up_model
    assert_equal %i[system user assistant user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/net_switch.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
