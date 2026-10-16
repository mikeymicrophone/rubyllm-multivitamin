# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "manuscript_refusal"

class LalibelaManuscriptRefusalTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_unsupported_operations_raise_locally_without_a_cassette
    refusals = play

    assert_instance_of RubyLLM::Error, refusals.fetch(:inscription_ids).fetch(:error)
    assert_equal :plain_text_ids, refusals.fetch(:inscription_ids).fetch(:capability)
    assert_match(/OpenAI.*text tokenization/, refusals.fetch(:inscription_ids).fetch(:message))
    assert_instance_of RubyLLM::Error, refusals.fetch(:request_count).fetch(:error)
    assert_equal :request_count, refusals.fetch(:request_count).fetch(:capability)
    assert_match(/OpenRouter.*token counting/, refusals.fetch(:request_count).fetch(:message))
    refute File.exist?(File.expand_path("cassettes/manuscript_refusal.yml", __dir__))
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "manuscript_refusal") { LalibelaManuscriptRefusal.conduct }
  end
end
