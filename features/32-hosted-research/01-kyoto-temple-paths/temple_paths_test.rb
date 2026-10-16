# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "temple_paths"

class KyotoTemplePathsTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/temple_paths.yml", __dir__)

  def test_temple_paths_research_flow
    original_project = RubyLLM.config.vertexai_project_id
    original_headers = RubyLLM::Providers::VertexAI.instance_method(:headers)
    card = Multivitamin::Cassettes.play(__dir__, "temple_paths") { KyotoTemplePaths.conduct }
    assert_equal original_headers, RubyLLM::Providers::VertexAI.instance_method(:headers)
    assert_equal [original_project], [RubyLLM.config.vertexai_project_id]
    assert_includes card.report, "Kyoto"
    assert_includes card.report, "temple grounds"
    assert card.sources.all? { |source| source.start_with?("https://") }
    refute_empty card.sources
    assert_operator card.tokens.input, :>, 0
    refute_empty card.thinking
    assert_equal "deep-research-preview-04-2026", requests.first.fetch("agent")
    refute requests.first.key?("model")
    assert_equal [{ "type" => "google_search" }], requests.first.fetch("tools")
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
