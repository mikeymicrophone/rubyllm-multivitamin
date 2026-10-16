# frozen_string_literal: true

require "minitest/autorun"
require_relative "lace_bobbin"

class GalleLaceBobbinTest < Minitest::Test
  def test_pending_slots_match_the_submitted_chats
    result = nil
    Multivitamin::Cassettes.play(__dir__, "lace_bobbin") do
      result = GalleLaceBobbin::BobbinBatch.conduct
    end

    assert_equal 2, result.size
    if result.complete
      assert_equal 2, result.slots.size
    else
      assert_equal [nil, nil], result.slots
    end
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/lace_bobbin.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
