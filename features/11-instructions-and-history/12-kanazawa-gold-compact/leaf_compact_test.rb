# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "leaf_compact"

class KanazawaGoldCompactTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/leaf_compact.yml", __dir__)

  def test_compact_keeps_four_turns_and_answers_from_the_summary
    result = nil
    Multivitamin::Cassettes.play(__dir__, "leaf_compact") do
      result = KanazawaGoldCompact::LeafCompact.conduct
    end

    assert_includes result.dh, "300"
    assert_includes result.humidity, "2"
    assert_match(/unchanged|printed/i, result.bench)
    assert_includes result.summary, "DH"
    assert_match(/300/, result.summary)
    assert_match(/Higashi Chaya|2 percent|burnishing|humidifier/i, result.summary)
    assert_match(/printed|moved|northwest|300/i, result.relief)
    assert_equal(
      %i[system user assistant user assistant user assistant user assistant],
      result.roles_before_compact
    )
    assert_equal %i[system user user assistant], result.roles_after_compact
    assert_equal 4, result.kept_count
    assert_equal %i[system user user assistant user assistant], result.roles
  end

  def test_last_request_drops_the_middle_notices
    last = request_bodies.last

    assert_includes last, "Daruma-haku lot DH"
    assert_includes last, "two-sentence handover"
    refute_includes last, "Overnight notice 2."
    refute_includes last, "Overnight notice 3."
    assert_includes last, "printed mark"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit|
      hit.dig("request", "body", "string")
    }
  end
end
