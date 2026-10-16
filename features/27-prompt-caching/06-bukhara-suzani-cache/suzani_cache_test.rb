# frozen_string_literal: true

require "minitest/autorun"
require_relative "suzani_cache"

class BukharaSuzaniCacheUnsupportedTest < Minitest::Test
  def test_openai_refuses_explicit_content_caching_before_http
    result = nil
    Multivitamin::Cassettes.play(__dir__, "suzani_cache") do
      result = BukharaSuzaniCache::SuzaniCache.conduct
    end

    assert_instance_of RubyLLM::Error, result.error
    refute_instance_of RubyLLM::BadRequestError, result.error
    assert_match(/doesn'?t support explicit content caching/i, result.message)
    refute File.exist?(File.expand_path("cassettes/suzani_cache.yml", __dir__))
  end
end
