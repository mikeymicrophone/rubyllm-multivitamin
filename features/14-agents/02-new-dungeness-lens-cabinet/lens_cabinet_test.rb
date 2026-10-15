# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "lens_cabinet"

class AgentNewDungenessLensCabinetTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/lens_cabinet.yml", __dir__)

  def test_the_keeper_calls_the_posted_drawer
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lens_cabinet") do
      result = NewDungenessLensCabinet::CabinetBrief.conduct
    end

    assert_equal NewDungenessLensCabinet::PostedLensDrawer::CARD, result.tool_content
    assert_includes result.answer, "ND-4"
    assert_includes result.tool_names, "posted_lens_drawer"
    assert_equal %i[system user assistant tool assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, '"name":"posted_lens_drawer"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
