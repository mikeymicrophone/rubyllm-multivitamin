# frozen_string_literal: true

require "minitest/autorun"
require_relative "retort_climb"

class RetortClimbTest < Minitest::Test
  def test_the_temperatures_survive_being_split_across_chunks
    result = nil
    Multivitamin::Cassettes.play(__dir__, "retort_climb") do
      result = AnacortesRetortClimb::RetortClimb.conduct
    end

    assert_equal result.speech, result.pieces.join
    assert_operator result.pieces.size, :>, 1
    assert result.same_message
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish_reason

    %w[180 210 240 242].each do |mark|
      assert_match(/#{mark}/, result.speech)
    end

    positions = %w[180 210 240 242].map { |mark| result.speech.index(mark) }
    assert_equal positions.sort, positions

    # 242 can be flushed as "24" and then "2". The join is the cook card.
    assert_match(/242/, result.pieces.join)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/retort_climb.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
