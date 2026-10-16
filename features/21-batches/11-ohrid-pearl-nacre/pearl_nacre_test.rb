# frozen_string_literal: true

require "minitest/autorun"
require_relative "pearl_nacre"

class OhridPearlNacreTest < Minitest::Test
  def test_one_refresh_updates_status_from_the_provider
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pearl_nacre") do
      result = OhridPearlNacre::NacreJob.conduct
    end

    refute_nil result.id
    assert_includes %i[pending succeeded failed cancelled], result.before
    assert_includes %i[pending succeeded failed cancelled], result.after
    assert_includes [true, false], result.complete
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/pearl_nacre.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
