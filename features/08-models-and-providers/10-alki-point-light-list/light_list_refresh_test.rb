# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "light_list_refresh"

class AlkiPointLightListRefreshTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/light_list_refresh.yml", __dir__)

  def test_refresh_pulls_the_published_catalog_and_restores_the_bundled_board
    result = nil
    Multivitamin::Cassettes.play(__dir__, "light_list_refresh") do
      result = AlkiPointLightList::Refresh.conduct
    end

    assert_operator result.before_count, :>, 100
    assert_operator result.after_count, :>, 100
    assert_equal "gpt-4.1-mini", result.mini_id
    assert_equal "openai", result.mini_provider
    assert result.wrote_registry

    bundled = RubyLLM.models.all.size
    assert_equal result.before_count, bundled
  end

  def test_cassette_records_the_published_catalog
    interactions = YAML.load_file(CASSETTE).fetch("http_interactions")
    uris = interactions.map { |interaction| interaction.dig("request", "uri").to_s }

    assert_operator interactions.size, :>=, 1
    assert uris.any? { |uri| uri.include?("rubyllm.com/models.json") }, uris.inspect
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
  end
end
