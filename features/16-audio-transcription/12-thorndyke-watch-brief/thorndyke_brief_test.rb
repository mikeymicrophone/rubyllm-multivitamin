# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "thorndyke_brief"

class TranscriptionThorndykeWatchBriefTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/thorndyke_brief.yml", __dir__)

  def test_the_tide_clerk_briefs_from_the_thorndyke_tape
    result = nil
    Multivitamin::Cassettes.play(__dir__, "thorndyke_brief") do
      result = ThorndykeWatchBrief::KelpBrief.conduct
    end

    assert_equal Multivitamin::Models::OPENAI_TRANSCRIBE, result.tape_model
    assert_match(/Thorndi[yk]e/i, result.tape_text)
    assert_match(/Alden/i, result.tape_text)
    assert_match(/kelp/i, result.tape_text)
    assert_match(/Alden/i, result.brief)
    assert_match(/kelp/i, result.brief)
    assert_equal %i[system user assistant], result.roles

    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    assert_equal 2, interactions.length
    assert_includes interactions.fetch(0).dig("request", "uri"), "audio/transcriptions"
    refute_includes interactions.fetch(1).dig("request", "uri"), "audio/transcriptions"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
