# frozen_string_literal: true

require "minitest/autorun"
require_relative "fault_warning"

class FaultWarningTest < Minitest::Test
  def test_the_fault_is_named_only_once_the_speech_is_joined
    result = nil
    Multivitamin::Cassettes.play(__dir__, "fault_warning") do
      result = ChristchurchFaultWarning::FaultWarning.conduct
    end

    assert_equal result.speech, result.pieces.join
    assert_match(/Alpine[[:space:]]+Fault/, result.speech)
    assert_includes result.speech, "35"
    assert_operator result.pieces.size, :>, 1

    assert_operator result.first_spoken_index, :>, 0
    leading = result.notes[0...result.first_spoken_index]
    assert leading.all? { |note| note.content.empty? }
    assert leading.any?(&:thinking)
    refute result.notes.first.content.include?("Alpine")

    assert_operator result.first_spoken_at, :>=, result.started_at
    assert_operator result.finished_at, :>=, result.first_spoken_at
    assert_operator result.first_spoken_at - result.started_at, :>=, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/fault_warning.yml", __dir__))

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
