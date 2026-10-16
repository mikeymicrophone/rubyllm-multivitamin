# frozen_string_literal: true

require "minitest/autorun"
require_relative "dhow_permit"

class ZanzibarDhowPermitTest < Minitest::Test
  def test_dhow_permit_waits_for_approval
    result = Multivitamin::Cassettes.play(__dir__, "dhow_permit") { ZanzibarDhowPermit.conduct }

    assert_equal %i[system user assistant], result.fetch(:parked)
    assert_equal "approved", result.fetch(:approval)
    assert_equal 1, result.fetch(:results)
    assert_includes result.fetch(:brief), "ZNZ-41"
    assert_includes result.fetch(:brief), "17:40"
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/dhow_permit.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
