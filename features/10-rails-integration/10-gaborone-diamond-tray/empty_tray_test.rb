# frozen_string_literal: true

require "minitest/autorun"
require_relative "empty_tray"

class PersistedGaboroneDiamondTrayTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/empty_tray.yml", __dir__)

  def test_empty_assistant_content_is_allowed
    result = nil
    Multivitamin::Cassettes.play(__dir__, "empty_tray") do
      result = GaboroneDiamondTray::TrayClerk.conduct
    end

    assert result.empty_persisted
    assert_equal "", result.empty_content
    assert_instance_of ActiveRecord::RecordInvalid, result.presence_error
    assert_match(/[Cc]ontent/, result.presence_error.message)
    assert_includes result.brief, "14:30"
    assert_includes result.brief, "4"
    assert_includes result.roles, :assistant
    assert_includes result.roles, :system
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-(?:or-v1-)?[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
