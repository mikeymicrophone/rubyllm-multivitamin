# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "oxygen_question"

class MaseruOxygenCapstoneTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/oxygen_question.yml", __dir__)

  def test_capability_filter_then_assume_answers_the_fill_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "oxygen_question") do
      result = MaseruOxygen::OxygenQuestion.conduct
    end

    assert_operator result.tool_clerk_count, :>, 100
    assert result.slug_has_tools
    assert_equal Multivitamin::Models::OPENAI_CHAT, result.chat_model_id
    assert_equal "openai", result.chat_provider
    assert_nil result.assumed_warning
    assert_match(/\A\s*Yes\b/i, result.brief.to_s)
    assert_includes result.brief, "Oxy-4"
    assert_match(/4(\.0)?/, result.brief)
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
  end

  def test_cassette_asks_the_recorded_slug
    body = YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0)
      .dig("request", "body", "string").to_s

    assert_includes body, Multivitamin::Models::OPENAI_CHAT
    assert_includes body, "Oxy-4"
    assert_includes body, "Thaba-Tseka"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
