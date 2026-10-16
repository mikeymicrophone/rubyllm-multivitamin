# frozen_string_literal: true

require "minitest/autorun"
require_relative "commission_board"

class ValenciaFallasBoardTest < Minitest::Test
  def test_chat_models_post_context_windows_without_opening_a_socket
    result = nil
    Multivitamin::Cassettes.play(__dir__, "commission_board") do
      result = ValenciaFallas::CommissionBoard.conduct
    end

    assert_operator result.chat_count, :>, 100
    assert_equal [:chat], result.types
    assert_operator result.openai_chat_count, :>, 0
    assert_equal result.openai_chat_count, result.openai_windows.size + result.openai_nil_windows
    result.openai_windows.each do |window|
      assert_kind_of Integer, window
      assert_operator window, :>=, 0
    end
    assert_equal "gpt-4.1-mini", result.long_board_id
    assert_equal "openai", result.long_board_provider
    assert_equal 1_047_576, result.long_board_window
    assert_includes result.openai_windows, 1_047_576
  end
end
