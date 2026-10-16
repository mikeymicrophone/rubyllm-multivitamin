# frozen_string_literal: true

require "minitest/autorun"
require_relative "floyen_closure"

class BergenFloyenClosureTest < Minitest::Test
  def test_floyen_closure_survives_denial
    result = Multivitamin::Cassettes.play(__dir__, "floyen_closure") { BergenFloyenClosure.conduct }

    assert_equal "denied", result.fetch(:approval)
    assert_includes result.fetch(:tool_result), "denied"
    assert_includes result.fetch(:brief), "closed"
    assert_includes result.fetch(:brief), "wind"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/floyen_closure.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
