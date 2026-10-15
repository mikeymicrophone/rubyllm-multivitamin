# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "creek_and_boom"

class CreekAndBoomTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/creek_and_boom.yml", __dir__)

  def test_the_creek_and_boom_run_on_separate_threads
    result = nil
    Multivitamin::Cassettes.play(__dir__, "creek_and_boom") do
      result = LilliwaupConcurrencyThreads::CreekWatch.conduct
    end

    assert_equal 2, result.call_count
    assert_equal %w[boom_log creek_stage], result.worker_names
    assert_equal 2, result.thread_ids.uniq.size
    assert_equal 2, result.tool_contents.size
    joined = result.tool_contents.join("\n")
    assert_includes joined, "3.8"
    assert_includes joined, "42 sticks"
    assert_includes result.answer, "3.8"
    assert_includes result.answer, "42"
    assert_equal %i[system user assistant tool tool assistant], result.roles

    request = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "body", "string")
    assert_includes request, '"parallel_tool_calls":true'
    refute_includes request, "3.8 ft"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
