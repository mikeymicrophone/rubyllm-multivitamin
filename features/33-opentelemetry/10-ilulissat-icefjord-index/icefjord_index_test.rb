# frozen_string_literal: true

require "minitest/autorun"
require_relative "icefjord_index"

class IlulissatIcefjordIndexTest < Minitest::Test
  def test_icefjord_index_trace
    capture = Multivitamin::Cassettes.play(__dir__, "icefjord_index") do
      IlulissatIcefjordIndex.conduct
    end

    assert_equal 3, capture.value.fetch(:vectors).size
    assert capture.value.fetch(:vectors).all? { |vector| vector.size == 3 }
    assert_equal({ "embeddings" => 1 }, capture.value.fetch(:counts))
    assert_equal 0, capture.value.fetch(:after_reset)
    assert_empty capture.spans
    snapshot = capture.value.fetch(:snapshot)
    assert snapshot.frozen?
    assert_equal 1, snapshot.size
    span = snapshot.first
    assert_equal "embeddings text-embedding-3-small", span.name
    assert_equal :client, span.kind
    assert_equal 3, span.attributes.fetch("gen_ai.embeddings.dimension.count")
    assert_equal capture.value.fetch(:tokens).input, span.attributes.fetch("gen_ai.usage.input_tokens")
    refute span.attributes.key?("gen_ai.usage.output_tokens")
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/icefjord_index.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
