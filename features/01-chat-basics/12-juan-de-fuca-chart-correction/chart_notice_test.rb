# frozen_string_literal: true

require "minitest/autorun"
require_relative "chart_notice"

class ChartNoticeTest < Minitest::Test
  def test_a_short_note_is_read_before_it_is_posted
    result = nil
    Multivitamin::Cassettes.play(__dir__, "chart_notice") do
      result = JuanDeFucaChart::ChartNotice.conduct
    end

    clipped_text = result.clipped_content.to_s.strip
    short_note = clipped_text.empty? || result.clipped_max_tokens || clipped_text.length < JuanDeFucaChart::ChartNotice::SHORT_LENGTH
    assert_equal short_note, result.asked_again
    assert_equal 200, result.clipped_status
    assert_equal 200, result.posted_status

    assert_includes result.posted_content, "18465"
    assert_includes result.posted_content, "DH"
    assert_match(/300/, result.posted_content)

    if result.asked_again
      assert_operator clipped_text.length, :<, result.posted_content.to_s.length
      assert_equal %i[system user assistant user assistant], result.roles
    else
      assert_equal result.clipped_content, result.posted_content
      assert_equal %i[system user assistant], result.roles
    end
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/chart_notice.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
