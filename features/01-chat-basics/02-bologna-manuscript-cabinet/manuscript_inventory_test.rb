# frozen_string_literal: true

require "minitest/autorun"
require_relative "manuscript_inventory"

class ManuscriptInventoryTest < Minitest::Test
  def test_one_ask_returns_the_message_readers
    result = nil
    Multivitamin::Cassettes.play(__dir__, "manuscript_inventory") do
      result = BolognaManuscriptCabinet::ManuscriptInventory.conduct
    end

    assert_includes result.content, "VF-17"
    assert_includes result.content, "BC-6"
    assert_match(/drawer B/i, result.content)
    assert_match(/\b6\b|six/i, result.content)

    assert_equal :assistant, result.role
    assert_equal Multivitamin::Models::CHAT, result.model_id
    assert_equal Multivitamin::Models::CHAT, result.chat_model_id
    assert_equal :stop, result.finish_reason
    assert_equal %i[system user assistant], result.roles

    assert_operator result.input_tokens, :>, 0
    assert_operator result.output_tokens, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/manuscript_inventory.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
