# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "orsi_window"

class OrsiWindowBase64Test < Minitest::Test
  CASSETTE = File.expand_path("cassettes/orsi_window.yml", __dir__)

  def test_the_orsi_window_arrives_as_inline_bytes_not_a_url
    result = nil
    Multivitamin::Cassettes.play(__dir__, "orsi_window") do
      result = IsfahanOrsiWindow::OrsiWindow.conduct
    end

    assert_nil result.url
    assert result.base64
    assert_operator result.data_bytes, :>, 0
    assert_equal "image/png", result.mime_type

    body = response_body
    assert_includes body, "b64_json"
    refute_includes body, '"url":"http'
    request = request_body
    refute_includes request, "response_format"
    assert_includes request, "Isfahan"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end

  def response_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
  end
end
