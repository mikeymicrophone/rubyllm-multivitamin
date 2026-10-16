# frozen_string_literal: true

require "minitest/autorun"
require_relative "carillon_tape"

class MechelenCarillonTapeTest < Minitest::Test
  def test_the_carillon_tape_stops_before_any_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "carillon_tape") do
      result = MechelenCarillon::CarillonTape.conduct
    end

    assert_instance_of RubyLLM::UnsupportedAttachmentError, result.error
    assert result.is_llm_error
    assert_includes result.mime, "audio/wav"
    assert_includes result.message, result.mime
    assert_nil result.response
    assert_nil result.shape
    refute File.exist?(File.expand_path("cassettes/carillon_tape.yml", __dir__))
  end
end
