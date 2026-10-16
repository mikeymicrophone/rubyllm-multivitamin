# frozen_string_literal: true

require "minitest/autorun"
require_relative "sealed_manifest"

class VeniceRialtoSealedManifestTest < Minitest::Test
  def test_sealed_manifest_trace
    capture = Multivitamin::Cassettes.play(__dir__, "sealed_manifest") do
      VeniceRialtoSealedManifest.conduct
    end

    assert_includes capture.value.fetch(:message).content, VeniceRialtoSealedManifest::PRIVATE_SEAL
    assert_equal ["chat.ruby_llm"], capture.value.fetch(:observed)
    exported = capture.spans.map { |span| [span.name, span.attributes, span.events, span.status.description] }.inspect
    refute_includes exported, VeniceRialtoSealedManifest::PRIVATE_SEAL
    refute_includes exported, "Lucia"
    refute_includes exported, "05:50"
    refute_match(/prompt|instructions|authorization|receiving_seal/i, exported)
    assert_equal "openai", capture.spans.find { |span| span.kind == :client }.attributes.fetch("gen_ai.provider.name")
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/sealed_manifest.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
