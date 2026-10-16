# frozen_string_literal: true

require "minitest/autorun"
require_relative "tadelakt"

class TaroudantTadelaktPartialTest < Minitest::Test
  def test_the_tone_partial_is_inside_the_card
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tadelakt") do
      result = TaroudantTadelaktPlaster::TadelaktPlaster.conduct
    end

    assert_includes result.tone_only, "Fatima"
    assert_includes result.card, result.tone_only.strip
    assert_includes result.card, "TAR-2026-1016-T3"
    refute File.exist?(File.expand_path("cassettes/tadelakt.yml", __dir__))
  end
end
