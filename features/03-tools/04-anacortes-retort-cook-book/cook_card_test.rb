# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cook_card"

class CookCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cook_card.yml", __dir__)

  def test_basket_three_comes_from_todays_book
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cook_card") do
      result = AnacortesRetortCookBook::MorningCook.conduct
    end

    assert_includes result.tool_content, "ANC-1014-B3"
    assert_includes result.tool_content, "242"
    assert_includes result.tool_content, "sockeye"
    assert_includes result.answer, "ANC-1014-B3"
    assert_equal %i[system user assistant tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"basket":{"type":"integer","description":"Basket number on the morning cook"}'
    refute_includes request, "ANC-1014-B3"
  end

  def test_the_instance_closes_over_the_open_book
    card = AnacortesRetortCookBook::RetortCookCard.new(cook_book: AnacortesRetortCookBook::MorningCook::TODAY)

    assert_equal "integer", card.parameters_schema.dig("properties", "basket", "type")
    assert_includes card.execute(basket: 3), "ANC-1014-B3"
    assert_includes card.execute(basket: "3"), "lot ANC-1014-B3"
    assert_includes card.execute(basket: 9), "No cook card for basket 9."
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
