# frozen_string_literal: true

require "minitest/autorun"
require_relative "sonnet_family"

class SuciaIslandSonnetFamilyTest < Minitest::Test
  def test_by_family_does_not_scrape_sonnet_out_of_every_id
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sonnet_family") do
      result = SuciaIslandWatch::SonnetFamily.conduct
    end

    assert_operator result.family_count, :>, 10
    assert result.all_family_match
    assert_includes result.providers, "anthropic"
    assert_includes result.providers, "bedrock"
    assert_kind_of String, result.anthropic_sample_id
    assert_includes result.anthropic_sample_id, "claude"
    assert_operator result.substring_ids.size, :>=, result.family_count
    assert_operator result.substring_outside_family.size, :>, 0
    result.substring_outside_family.each do |provider, id, family|
      assert_includes id, "sonnet"
      refute_equal "claude-sonnet", family
      assert_kind_of String, provider
    end
    assert_equal "ArgumentError", result.block_find_error
    assert_includes result.block_find_message, "wrong number of arguments"
  end
end
