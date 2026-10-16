# frozen_string_literal: true

require "minitest/autorun"
require_relative "causeway_trials"

class AngkorWatCausewayTrialsTest < Minitest::Test
  def test_causeway_trials_trace
    capture = Multivitamin::Cassettes.play(__dir__, "causeway_trials") do
      AngkorWatCausewayTrials::CausewayInspection.conduct
    end

    assert capture.value.passed?
    assert_equal 2, capture.value.trials.size
    assert capture.value.trials.all? { |trial| trial.assertion_count >= 2 && trial.evaluations.empty? }
    roots = capture.spans.select { |span| span.name.start_with?("invoke_workflow ") }
    assert_equal 2, roots.size
    assert_equal 2, roots.map(&:trace_id).uniq.size
    assert_equal 2, capture.spans.count { |span| span.name == "ruby_llm.workflow_step perform" }
    assert_equal 2, capture.spans.count { |span| span.name == "ruby_llm.workflow_step evaluate" }
    capture.spans.select { |span| span.kind == :client }.each do |span|
      parent = capture.spans.find { |candidate| candidate.span_id == span.parent_span_id }
      assert_equal "ruby_llm.workflow_step perform", parent.name
    end
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/causeway_trials.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
