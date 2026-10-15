# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "cook_prompt"

class AnacortesMcpPromptAskTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/cook_prompt.yml", __dir__)

  def test_ask_plays_the_prompt_turns_then_the_cook_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "cook_prompt") do
      result = AnacortesMcpPrompt::CookPrompt.conduct
    end

    assert_equal "retort_cook_brief", result.prompt_name
    assert_equal %i[user assistant user], result.prompt_turns
    assert_equal %i[system user assistant user assistant], result.roles
    assert_includes result.answer, "Retort"
    assert_match(/242/, result.answer)
    assert_match(/74/, result.answer)

    request = request_bodies.fetch(0)
    assert_includes request, "basket 3"
    assert_includes request, "74 minutes"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
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
