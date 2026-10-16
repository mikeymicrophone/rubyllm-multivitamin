# frozen_string_literal: true

require "minitest/autorun"
require_relative "vault_stream"

class SvalbardSeedVaultStreamTest < Minitest::Test
  def test_vault_stream_trace
    capture = Multivitamin::Cassettes.play(__dir__, "vault_stream") do
      SvalbardSeedVaultStream.conduct
    end

    assert_equal capture.value.fetch(:message).content, capture.value.fetch(:speech)
    assert_includes capture.value.fetch(:speech), "Ingrid"
    refute_empty capture.value.fetch(:observations)
    assert capture.value.fetch(:observations).all? { |finished, current| finished.zero? && current }
    assert_equal 1, capture.spans.size
    span = capture.spans.first
    assert_equal true, span.attributes.fetch("gen_ai.request.stream")
    assert_equal "openrouter", span.attributes.fetch("gen_ai.provider.name")
    assert_equal capture.value.fetch(:message).tokens.output, span.attributes.fetch("gen_ai.usage.output_tokens")
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/vault_stream.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
