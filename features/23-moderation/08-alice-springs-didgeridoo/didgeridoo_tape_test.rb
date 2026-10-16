# frozen_string_literal: true

require "minitest/autorun"
require_relative "didgeridoo_tape"

class AliceSpringsDidgeridooTapeTest < Minitest::Test
  def test_the_rehearsal_tape_stops_before_any_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "didgeridoo_tape") do
      result = AliceSpringsDidgeridoo::DidgeridooTape.conduct
    end

    assert_instance_of RubyLLM::UnsupportedAttachmentError, result.error
    assert result.is_llm_error
    assert_includes result.mime, "audio/wav"
    assert_includes result.error.message, result.mime
    refute File.exist?(File.expand_path("cassettes/didgeridoo_tape.yml", __dir__))
  end
end
