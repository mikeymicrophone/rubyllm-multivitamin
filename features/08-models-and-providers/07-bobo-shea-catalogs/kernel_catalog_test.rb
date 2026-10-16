# frozen_string_literal: true

require "minitest/autorun"
require_relative "kernel_catalog"

class BoboSheaKernelCatalogTest < Minitest::Test
  def test_embedding_and_chat_catalogs_do_not_share_a_drawer
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kernel_catalog") do
      result = BoboShea::KernelCatalog.conduct
    end

    assert_operator result.chat_count, :>, 100
    assert_operator result.embedding_count, :>, 10
    assert_equal [], result.overlap
    assert_equal [], result.id_only_overlap
    assert_equal "text-embedding-3-small", result.embedding_sample_id
    assert_equal :embedding, result.embedding_sample_type
    assert_equal "openai", result.embedding_sample_provider
    refute result.embedding_in_chat
    assert_equal "gpt-4.1-mini", result.chat_sample_id
    assert_equal :chat, result.chat_sample_type
    refute result.chat_in_embedding
  end
end
