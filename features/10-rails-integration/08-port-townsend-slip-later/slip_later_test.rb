# frozen_string_literal: true

require "minitest/autorun"
require_relative "slip_later"

class PersistedPortTownsendSlipLaterTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/slip_later.yml", __dir__)

  def test_ask_later_waits_and_complete_fills_the_row
    result = nil
    Multivitamin::Cassettes.play(__dir__, "slip_later") do
      result = PortTownsendSlipLater::SlipClerk.conduct
    end

    assert_includes result.brief, "28"
    assert_match(/Kalakala/i, result.brief)
    assert_equal 2, result.count_after_later
    assert_equal 1, result.user_count_after_later
    assert_equal 0, result.assistant_after_later
    assert_equal 3, result.count_after_complete
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
