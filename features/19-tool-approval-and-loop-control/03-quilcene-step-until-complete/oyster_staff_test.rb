# frozen_string_literal: true

require "minitest/autorun"
require_relative "oyster_staff"

class OysterStaffTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/oyster_staff.yml", __dir__)

  def test_step_walks_the_oyster_staff_until_the_beds_are_posted
    result = nil
    Multivitamin::Cassettes.play(__dir__, "oyster_staff") do
      result = QuilceneStepUntilComplete::BedClerk.conduct
    end

    refute result.complete_after_later
    assert_equal %i[assistant tool assistant], result.move_roles
    assert_nil result.second_step
    assert result.settled
    refute result.waiting
    assert_equal QuilceneStepUntilComplete::PostedOysterStaff::STAFF, result.tool_content
    assert_includes result.answer, "08:10"
    assert_includes result.answer, "Linger Longer"
    assert_equal %i[system user assistant tool assistant], result.roles
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
