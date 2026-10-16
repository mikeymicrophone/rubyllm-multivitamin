# frozen_string_literal: true

require "minitest/autorun"
require_relative "khachkar"

class GyumriKhachkarQuestionTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/khachkar.yml", __dir__)

  def test_the_rendered_question_names_aram
    result = nil
    Multivitamin::Cassettes.play(__dir__, "khachkar") do
      result = GyumriKhachkarCarving::KhachkarCarving.conduct
    end

    assert_includes result.question, "Aram"
    assert_includes result.question, "GYU-2026-1016-K8"
    assert_includes result.brief, "Aram"
    assert_includes result.brief, "11:40"
    assert_equal %i[system user assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
