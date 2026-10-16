# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "karkade"

class KhartoumHibiscusOffTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/karkade.yml", __dir__)

  def test_nemotron_off_sends_enabled_false
    result = nil
    Multivitamin::Cassettes.play(__dir__, "karkade") do
      result = KhartoumHibiscusKarkade::Karkade.conduct
    end

    assert_includes result.brief, "Maha"
    assert_includes result.brief, "05:45"
    assert_equal false, result.enabled[:enabled]
    assert_nil result.thinking_text
    assert_includes request_body, '"enabled":false'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string").to_s
  end
end
