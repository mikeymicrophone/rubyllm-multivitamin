# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "hydrometer_roles"

class HobartHydrometerRolesTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/hydrometer_roles.yml", __dir__)

  def test_roles_read_back_as_system_user_assistant
    result = nil
    Multivitamin::Cassettes.play(__dir__, "hydrometer_roles") do
      result = HobartHydrometerRoles::HydrometerRoles.conduct
    end

    assert_equal %i[system user assistant], result.roles
    assert_equal :assistant, result.assistant_role
    assert_includes result.system_content, "still-house clerk at the Chen family whisky warehouse in Hobart"
    assert_includes result.user_content, "29.92"
    assert_equal result.round, result.assistant_content
    assert_includes result.round, "29.92"
    assert_match(/falling/i, result.round)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
