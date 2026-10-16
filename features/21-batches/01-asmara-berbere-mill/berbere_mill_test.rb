# frozen_string_literal: true

require "minitest/autorun"
require_relative "berbere_mill"

class AsmaraBerbereMillTest < Minitest::Test
  def test_ask_later_then_batch_returns_an_id
    result = nil
    Multivitamin::Cassettes.play(__dir__, "berbere_mill") do
      result = AsmaraBerbereMill::MillBatch.conduct
    end

    refute_nil result.batch_id
    refute_empty result.batch_id.to_s
    assert_includes %i[pending succeeded failed cancelled], result.status
    assert_equal 2, result.chat_count
    assert_includes [true, false], result.complete
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/berbere_mill.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
