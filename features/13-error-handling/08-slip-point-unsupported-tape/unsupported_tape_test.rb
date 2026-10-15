# frozen_string_literal: true

require "minitest/autorun"
require_relative "unsupported_tape"

class SlipPointUnsupportedTapeTest < Minitest::Test
  def test_the_diaphone_tape_stops_before_any_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "unsupported_tape") do
      result = SlipPointUnsupportedTape::UnsupportedTape.conduct
    end

    assert_instance_of RubyLLM::UnsupportedAttachmentError, result.error
    assert result.is_llm_error
    assert_includes result.mime, "audio/wav"
    assert_includes result.message, result.mime
    assert_nil result.response
    assert_nil result.shape
    refute File.exist?(File.expand_path("cassettes/unsupported_tape.yml", __dir__))
  end
end
