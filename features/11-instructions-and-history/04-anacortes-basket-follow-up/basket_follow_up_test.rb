# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "basket_follow_up"

class AnacortesBasketFollowUpTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/basket_follow_up.yml", __dir__)

  def test_follow_up_uses_the_card_without_repeating_it
    result = nil
    Multivitamin::Cassettes.play(__dir__, "basket_follow_up") do
      result = AnacortesBasketFollowUp::BasketFollowUp.conduct
    end

    assert_match(/basket 7/i, result.late_basket)
    assert_includes result.come_up, "06:40"
    assert_match(/7/, result.come_up)
    assert_equal %i[system user assistant user assistant], result.roles
    assert_equal AnacortesBasketFollowUp::BasketFollowUp::FOLLOW_UP, result.follow_up_text
    refute_includes result.follow_up_text, "Basket 7"
    assert result.card_still_present
  end

  def test_second_request_resends_the_cook_card
    first, second = request_bodies

    assert_includes first, "Basket 7"
    refute_includes first, "that late basket"
    assert_includes second, "Basket 7"
    assert_includes second, "that late basket"
    assert_includes second, "06:40"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit|
      hit.dig("request", "body", "string")
    }
  end
end
