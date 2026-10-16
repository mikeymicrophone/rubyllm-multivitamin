# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "railway_archive"

class NairobiRailwayArchiveTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/railway_archive.yml", __dir__)

  def test_railway_archive_research_flow
    archive = Multivitamin::Cassettes.play(__dir__, "railway_archive") { NairobiRailwayArchive.conduct }
    assert_includes archive.fetch(:brief), "Nairobi"
    assert_includes archive.fetch(:brief), "queue"
    assert_includes archive.fetch(:tools), "microsoft_docs_search"
    assert archive.fetch(:sources).any? { |source| source.start_with?("https://learn.microsoft.com/") }
    assert_equal [{ "type" => "mcp_server", "name" => "learn", "url" => "https://learn.microsoft.com/api/mcp" }], requests.first.fetch("tools")
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
