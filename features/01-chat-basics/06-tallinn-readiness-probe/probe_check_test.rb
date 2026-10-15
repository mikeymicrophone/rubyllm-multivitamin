# frozen_string_literal: true

require "minitest/autorun"
require_relative "probe_check"

class ProbeCheckTest < Minitest::Test
  def test_two_models_answer_one_probe_question_and_with_model_keeps_the_transcript
    result = nil
    Multivitamin::Cassettes.play(__dir__, "probe_check") do
      result = TallinnReadinessProbe::ProbeCheck.conduct
    end

    assert_equal Multivitamin::Models::CHAT, result.nemotron_model_id
    assert_match(/\A\s*Yes\b/i, result.nemotron)
    assert_includes result.nemotron, "9"
    assert_includes result.nemotron, "8.4"

    assert_equal Multivitamin::Models::CHAT_FALLBACK, result.liquid_model_id
    refute_equal result.nemotron_model_id, result.liquid_model_id
    assert_includes result.liquid.to_s, "9"

    assert_equal Multivitamin::Models::CHAT_FALLBACK, result.spare_model_id
    assert_equal Multivitamin::Models::CHAT_FALLBACK, result.switched_chat_model_id
    assert_includes result.spare, "6"
    assert result.first_user_still_present

    assert_equal %i[system user assistant user assistant], result.switched_roles
    assert_equal %i[system user assistant], result.fresh_roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/probe_check.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
