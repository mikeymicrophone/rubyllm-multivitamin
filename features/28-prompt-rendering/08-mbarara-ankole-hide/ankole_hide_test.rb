# frozen_string_literal: true

require "minitest/autorun"
require_relative "ankole_hide"

class MbararaAnkoleHideMissingPromptTest < Minitest::Test
  def test_prompt_instructions_fails_loudly_when_the_file_is_absent
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ankole_hide") do
      result = MbararaAnkoleHide::AnkoleHide.conduct
    end

    assert_instance_of RubyLLM::PromptNotFoundError, result.error
    assert_match(/Prompt file not found/, result.message)
    assert_match(/mbarara_ankole_hide\/hide_clerk\/instructions/, result.message)
    refute File.exist?(File.expand_path("cassettes/ankole_hide.yml", __dir__))
  end
end
