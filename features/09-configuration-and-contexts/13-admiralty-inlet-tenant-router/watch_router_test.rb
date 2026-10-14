# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "watch_router"

class AdmiraltyTenantRouterTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/watch_router.yml", __dir__)

  def test_the_router_vends_two_contexts_and_rebinding_leaves_the_global_title
    result = nil
    Multivitamin::Cassettes.play(__dir__, "watch_router") do
      result = AdmiraltyInletTenantRouter::WatchRouter.conduct
    end

    assert_includes result.station_brief, "07:05"
    assert_match(/horn/i, result.station_brief)
    assert_includes result.cannery_log, "242"
    assert_equal AdmiraltyInletTenantRouter::WatchRouter::STATION.title, result.station_title
    assert_equal AdmiraltyInletTenantRouter::WatchRouter::CANNERY.title, result.cannery_title
    assert_equal result.cannery_title, result.rebound_context_title
    assert_equal "RubyLLM Multivitamin", result.global_title
    assert_equal "point-wilson-overnight", result.station_headers["X-Admiralty-Watch"]

    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    titles = interactions.map { |interaction| Array(interaction.dig("request", "headers", "X-Openrouter-Title")).join }
    watch = interactions.fetch(0).dig("request", "headers", "X-Admiralty-Watch")
    assert_includes titles, AdmiraltyInletTenantRouter::WatchRouter::STATION.title
    assert_includes titles, AdmiraltyInletTenantRouter::WatchRouter::CANNERY.title
    assert_equal ["point-wilson-overnight"], watch
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
