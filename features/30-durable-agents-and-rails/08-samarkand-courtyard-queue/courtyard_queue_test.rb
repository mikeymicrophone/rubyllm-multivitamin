# frozen_string_literal: true

require "minitest/autorun"
require_relative "courtyard_queue"

class SamarkandCourtyardQueueTest < Minitest::Test
  def test_courtyard_queue_parks_after_available_work
    result = Multivitamin::Cassettes.play(__dir__, "courtyard_queue") { SamarkandCourtyardQueue.conduct }

    assert_equal 2, result.fetch(:jobs)
    assert_equal 0, result.fetch(:queued)
    assert result.fetch(:waiting)
    refute result.fetch(:complete)
    assert_equal ["open_courtyard"], result.fetch(:pending)
    assert_equal 1, result.fetch(:role_counts).fetch("tool")
    assert_includes result.fetch(:roster), "Aziza"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/courtyard_queue.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
