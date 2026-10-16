# frozen_string_literal: true

require "minitest/autorun"
require_relative "torii_watch"

class KyotoToriiWatchTest < Minitest::Test
  def test_one_job_per_torii_move
    result = Multivitamin::Cassettes.play(__dir__, "torii_watch") { KyotoToriiWatch.conduct }

    assert_equal 3, result.fetch(:jobs)
    assert result.fetch(:complete)
    assert_includes result.fetch(:brief), "2.4 m"
    assert_includes result.fetch(:brief), "06:20"
    assert_equal %i[system user assistant tool assistant], result.fetch(:roles)
    assert_equal 2, result.fetch(:usages)
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/torii_watch.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
