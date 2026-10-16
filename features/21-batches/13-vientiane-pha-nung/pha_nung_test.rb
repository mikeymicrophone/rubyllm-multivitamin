# frozen_string_literal: true

require "minitest/autorun"
require_relative "pha_nung"

class VientianePhaNungTest < Minitest::Test
  def test_the_nung_desk_submits_finds_and_refreshes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pha_nung") do
      result = VientianePhaNung::NungDesk.conduct
    end

    assert_equal result.submitted_id, result.found_id
    assert_equal 2, result.message_slots
    assert_includes %i[pending succeeded failed cancelled], result.status
    assert_includes [true, false], result.complete
    assert_instance_of Array, result.statuses
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/pha_nung.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
