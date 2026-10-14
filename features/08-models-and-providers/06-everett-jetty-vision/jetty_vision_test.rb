# frozen_string_literal: true

require "minitest/autorun"
require_relative "jetty_vision"

class EverettJettyVisionFilterTest < Minitest::Test
  def test_vision_filter_keeps_only_clerks_who_can_read_the_aerial
    result = nil
    Multivitamin::Cassettes.play(__dir__, "jetty_vision") do
      result = EverettJetty::VisionFilter.conduct
    end

    assert_operator result.openai_chat_count, :>, 0
    assert_operator result.vision_count, :>, 0
    assert_operator result.blind_count, :>, 0
    assert_equal result.openai_chat_count, result.vision_count + result.blind_count
    assert result.all_vision_support
    assert_equal "gpt-4.1-mini", result.sample_id
    assert_equal "openai", result.sample_provider
    assert result.sample_vision
  end
end
