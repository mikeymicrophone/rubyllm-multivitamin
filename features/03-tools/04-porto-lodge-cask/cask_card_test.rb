# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cask_card"

class CaskCardTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cask_card.yml", __dir__)

  def test_cask_three_comes_from_todays_book
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cask_card") do
      result = PortoLodgeCask::MorningLodge.conduct
    end

    assert_includes result.tool_content, "PRT-1014-C3"
    assert_includes result.tool_content, "82"
    assert_includes result.tool_content, "touriga"
    assert_includes result.answer, "PRT-1014-C3"
    assert_equal %i[system user assistant tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"cask":{"type":"integer","description":"Cask number on the morning lodge round"}'
    refute_includes request, "PRT-1014-C3"
  end

  def test_the_instance_closes_over_the_open_book
    card = PortoLodgeCask::LodgeCaskCard.new(lodge_book: PortoLodgeCask::MorningLodge::TODAY)

    assert_equal "integer", card.parameters_schema.dig("properties", "cask", "type")
    assert_includes card.execute(cask: 3), "PRT-1014-C3"
    assert_includes card.execute(cask: "3"), "lot PRT-1014-C3"
    assert_includes card.execute(cask: 9), "No lodge card for cask 9."
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
