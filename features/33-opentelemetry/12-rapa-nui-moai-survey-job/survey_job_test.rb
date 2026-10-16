# frozen_string_literal: true

require "minitest/autorun"
require_relative "survey_job"

class RapaNuiMoaiSurveyJobTest < Minitest::Test
  def test_survey_job_trace
    capture = Multivitamin::Cassettes.play(__dir__, "survey_job") do
      RapaNuiMoaiSurveyJob.conduct
    end

    assert_includes capture.value.content, "Hina"
    assert_includes capture.value.content, "09:45"
    dispatch = capture.spans.find { |span| span.name == "Dispatch survey" }
    workflow = capture.spans.find { |span| span.name == "invoke_workflow Survey briefing" }
    chat = capture.spans.find { |span| span.kind == :client }
    assert_equal 3, capture.spans.size
    assert_equal dispatch.span_id, workflow.parent_span_id
    assert_equal workflow.span_id, chat.parent_span_id
    assert_equal 1, capture.spans.map(&:trace_id).uniq.size
    refute OpenTelemetry::Trace.current_span.context.valid?
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/survey_job.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
