# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tenants"

class SoussePressAndStallTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tenants.yml", __dir__)

  def test_two_contexts_keep_their_titles_and_leave_the_global_config
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tenants") do
      result = SoussePressAndStall::Tenants.conduct
    end

    assert_includes result.mill_brief, "Youssef"
    assert_includes result.mill_brief, "06:40"
    assert_includes result.stall_log, "harissa"
    assert_includes result.stall_log, "12"
    assert_equal SoussePressAndStall::Tenants::MILL_TITLE, result.mill_title
    assert_equal SoussePressAndStall::Tenants::STALL_TITLE, result.stall_title
    assert_equal SoussePressAndStall::Tenants::GLOBAL_TITLE, result.global_title_after
    assert_equal "https://github.com/mikeymicrophone/rubyllm-multivitamin", result.global_url_after

    titles = request_headers.map { |headers| Array(headers["X-Openrouter-Title"]).join }
    assert_includes titles, SoussePressAndStall::Tenants::MILL_TITLE
    assert_includes titles, SoussePressAndStall::Tenants::STALL_TITLE
    refute_includes titles, SoussePressAndStall::Tenants::GLOBAL_TITLE
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_headers
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "headers")
    end
  end
end
