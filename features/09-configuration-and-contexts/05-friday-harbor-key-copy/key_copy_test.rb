# frozen_string_literal: true

require "minitest/autorun"
require_relative "key_copy"

class FridayHarborKeyCopyTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/key_copy.yml", __dir__)

  def test_a_tenant_key_on_one_context_leaves_the_global_key
    result = nil
    Multivitamin::Cassettes.play(__dir__, "key_copy") do
      result = FridayHarborKeyCopy::KeyCopy.conduct
    end

    assert_includes result.assignment, "Alden"
    assert_includes result.assignment, "G-14"
    assert_equal FridayHarborKeyCopy::KeyCopy::SPARE_KEY, result.spare_key
    refute result.spare_matches_global
    assert_equal result.global_key, result.working_key
    refute_equal result.spare_key, result.global_key
    refute_includes result.global_key.to_s, "friday-harbor-tenant-copy"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_includes cassette, FridayHarborKeyCopy::KeyCopy::SPARE_KEY
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
