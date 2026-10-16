# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "booking_desk"

class ArushaBookingDeskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/booking_desk.yml", __dir__)

  def test_the_clean_card_is_briefed
    result = nil
    Multivitamin::Cassettes.play(__dir__, "booking_desk") do
      result = ArushaBookingDesk::BookingDesk.conduct
    end

    refute result.flagged
    assert result.briefed
    assert_includes result.brief, "Asha"
    assert_includes result.brief, "07:15"
    assert_equal %i[system user assistant], result.roles
    assert_equal 2, interactions.length
    assert_includes interactions.fetch(0).dig("request", "uri"), "moderations"
    assert_includes interactions.fetch(1).dig("request", "uri"), "api.openai.com"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
