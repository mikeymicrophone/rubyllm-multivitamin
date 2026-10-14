# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "horn_append"

class CapeDisappointmentHornAppendTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/horn_append.yml", __dir__)

  def test_append_keeps_both_system_messages
    result = nil
    Multivitamin::Cassettes.play(__dir__, "horn_append") do
      result = CapeDisappointmentHornAppend::HornAppend.conduct
    end

    assert_equal 2, result.system_texts.length
    assert_includes result.system_texts[0], "posted blast-card orders"
    assert_includes result.system_texts[1], "Appended visibility rule"
    assert_equal %i[system system user assistant], result.roles
    assert_match(/\A\s*Yes\b/i, result.brief.to_s)
    assert_match(/horn/i, result.brief)
    assert_match(/visibility|1 mile|fair/i, result.brief)
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0
  end

  def test_cassette_sends_both_system_texts
    body = request_bodies.fetch(0)

    assert_includes body, "posted blast-card orders"
    assert_includes body, "Appended visibility rule"
    assert_includes body, "0.6"
    assert_includes body, "blast time.\\n\\nAppended visibility rule"
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
