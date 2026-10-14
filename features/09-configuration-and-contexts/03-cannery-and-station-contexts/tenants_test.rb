# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tenants"

class CanneryStationTenantsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tenants.yml", __dir__)

  def test_two_contexts_keep_their_titles_and_leave_the_global_config
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tenants") do
      result = CanneryAndStationTenants::Tenants.conduct
    end

    assert_includes result.station_brief, "Alden"
    assert_includes result.station_brief, "10:46"
    assert_includes result.cannery_log, "242"
    assert_includes result.cannery_log, "2"
    assert_equal CanneryAndStationTenants::Tenants::STATION_TITLE, result.station_title
    assert_equal CanneryAndStationTenants::Tenants::CANNERY_TITLE, result.cannery_title
    assert_equal CanneryAndStationTenants::Tenants::GLOBAL_TITLE, result.global_title_after
    assert_equal "https://github.com/mikeymicrophone/rubyllm-multivitamin", result.global_url_after

    titles = request_headers.map { |headers| Array(headers["X-Openrouter-Title"]).join }
    assert_includes titles, CanneryAndStationTenants::Tenants::STATION_TITLE
    assert_includes titles, CanneryAndStationTenants::Tenants::CANNERY_TITLE
    refute_includes titles, CanneryAndStationTenants::Tenants::GLOBAL_TITLE
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
