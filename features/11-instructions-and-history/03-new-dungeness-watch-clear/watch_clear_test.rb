# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "watch_clear"

class NewDungenessWatchClearTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/watch_clear.yml", __dir__)

  def test_clearing_instructions_drops_system_and_keeps_the_cabinet
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_clear") do
      result = NewDungenessWatchClear::WatchClear.conduct
    end

    assert_includes result.cabinet, "NB-17"
    assert_match(/drawer B/i, result.cabinet)
    assert_includes result.chimneys, "LC-6"
    assert_match(/\bsix\b|\b6\b/i, result.chimneys)
    assert_equal %i[system user assistant], result.roles_before_clear
    assert_equal %i[user assistant], result.roles_after_clear
    assert_equal %i[user assistant user assistant], result.roles
    assert_equal :stop, result.finish
  end

  def test_second_request_has_no_system_instructions
    first, second = request_bodies

    assert_includes first, "lens-room standing orders"
    refute_includes second, "lens-room standing orders"
    refute_includes second, '"instructions":'
    assert_includes second, "NB-17"
    assert_includes second, "drawer C"
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
