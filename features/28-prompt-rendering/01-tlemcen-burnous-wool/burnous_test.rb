# frozen_string_literal: true

require "minitest/autorun"
require_relative "burnous"

class TlemcenBurnousWoolTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/burnous.yml", __dir__)

  def test_the_rendered_orders_name_yasmina
    result = nil
    Multivitamin::Cassettes.play(__dir__, "burnous") do
      result = TlemcenBurnousWool::BurnousDesk.conduct
    end

    assert_includes result.rendered, "Yasmina"
    assert_includes result.rendered, "TLM-2026-1016-B4"
    assert_includes result.brief, "Yasmina"
    assert_includes result.brief, "09:15"
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
