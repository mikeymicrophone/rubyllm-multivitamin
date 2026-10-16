# frozen_string_literal: true

require "minitest/autorun"
require_relative "hops_kiln"

class NelsonHopsKilnBatchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/hops_kiln.yml", __dir__)

  def test_the_jsonl_stores_as_a_batch_file
    result = nil
    Multivitamin::Cassettes.play(__dir__, "hops_kiln") do
      result = NelsonHopsKiln::HopsKiln.conduct
    end

    assert_match(/\Afile-/, result.file_id)
    assert_equal "batch", result.purpose
    assert_includes result.filename, "hops-batch"
    assert_operator result.byte_size, :>, 0
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
