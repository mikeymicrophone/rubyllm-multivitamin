# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "funicular_sources"

class ValparaisoFunicularSourcesTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/funicular_sources.yml", __dir__)

  def test_funicular_sources_research_flow
    ledger = Multivitamin::Cassettes.play(__dir__, "funicular_sources") { ValparaisoFunicularSources.conduct }
    report = ledger.fetch(:report)
    assert_includes report.content, "Valparaíso"
    assert_equal 2, report.citations.length
    report.citations.each do |citation|
      assert_equal citation.text, report.content[citation.start_index...citation.end_index]
      refute_empty citation.text
      assert ledger.fetch(:sources).key?(citation.url)
    end
    refute RubyLLM::Citation.method_defined?(:source_label)
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end
end
