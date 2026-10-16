# frozen_string_literal: true

require "minitest/autorun"
require_relative "wall_watch"

class DubrovnikWallWatchTest < Minitest::Test
  def test_wall_watch_trace
    capture = Multivitamin::Cassettes.play(__dir__, "wall_watch") do
      DubrovnikWallWatch.conduct
    end

    assert_equal %w[Pile Minčeta Ploče], capture.value.fetch(:walked)
    assert_equal 2, capture.value.fetch(:finished_before_application)
    assert_equal ["ruby_llm.workflow_step Walk sector", "invoke_workflow Wall inspection", "Archive wall card"], capture.spans.map(&:name)
    assert_equal "wall-crew", capture.spans.last.instrumentation_scope.name
    assert capture.spans.all? { |span| span.end_timestamp >= span.start_timestamp }
  end

  def test_no_provider_fixture_is_needed
    refute File.exist?(File.expand_path("cassettes/wall_watch.yml", __dir__))
  end
end
