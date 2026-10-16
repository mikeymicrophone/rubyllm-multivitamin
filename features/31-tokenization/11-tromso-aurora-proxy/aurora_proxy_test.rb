# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "aurora_proxy"

class TromsoAuroraProxyTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_the_tokenizer_uses_the_backend_proxy_without_v1
    result = play
    tokens = result.fetch(:tokenization)
    request = requests.fetch(0)

    assert_equal Multivitamin::Models::GPUSTACK_TOKENIZER, tokens.model
    assert_equal tokens.raw.fetch("tokens"), tokens.ids
    assert_equal tokens.count, tokens.raw.fetch("count")
    assert_equal tokens.count - 1, result.fetch(:pairs).length
    assert_equal tokens.ids.first(2), result.fetch(:pairs).first
    assert_equal %w[model prompt], request.keys.sort
    assert_includes request.fetch("prompt"), "Sigrid closes lens TRO-3 at 23:40"
    assert_match(%r{/model/proxy/7/tokenize\z}, interactions.fetch(0).dig("request", "uri"))
    refute_match(%r{/v1/tokenize\z}, interactions.fetch(0).dig("request", "uri"))
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "aurora_proxy", key: "GPUSTACK_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "aurora_proxy") { TromsoAuroraProxy.conduct }
  end

  def requests = cassette_requests(__dir__, "aurora_proxy")
  def interactions = cassette_interactions(__dir__, "aurora_proxy")
end
