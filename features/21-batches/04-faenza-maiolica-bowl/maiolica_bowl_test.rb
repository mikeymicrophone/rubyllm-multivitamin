# frozen_string_literal: true

require "minitest/autorun"
require_relative "maiolica_bowl"

class FaenzaMaiolicaBowlTest < Minitest::Test
  def test_the_tool_round_then_the_follow_up_enters_a_batch
    result = nil
    Multivitamin::Cassettes.play(__dir__, "maiolica_bowl") do
      result = FaenzaMaiolicaBowl::BowlBatch.conduct
    end

    assert_includes result.tool_roles, :tool
    assert result.awaiting
    refute_nil result.batch_id
    assert_includes %i[pending succeeded failed cancelled], result.status
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/maiolica_bowl.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
