# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "accession_notice"

class AccessionNoticeTest < Minitest::Test
  def test_a_short_note_is_read_before_it_is_posted
    result = nil
    Multivitamin::Cassettes.play(__dir__, "accession_notice") do
      result = SingaporeAccession::AccessionNotice.conduct
    end

    assert_nil result.clipped_content
    assert_includes result.clipped_thinking, "18465"
    assert_equal :max_tokens, result.clipped_finish
    assert_equal true, result.clipped_max_tokens

    clipped_text = result.clipped_content.to_s.strip
    short_note = clipped_text.empty? || result.clipped_max_tokens || clipped_text.length < SingaporeAccession::AccessionNotice::SHORT_LENGTH
    assert_equal short_note, result.asked_again
    assert_equal 200, result.clipped_status
    assert_equal 200, result.posted_status

    assert_includes result.posted_content, "18465"
    assert_includes result.posted_content, "DH"
    assert_match(/300/, result.posted_content)

    if result.asked_again
      assert_operator clipped_text.length, :<, result.posted_content.to_s.length
      assert_equal %i[system user assistant user assistant], result.roles
    else
      assert_equal result.clipped_content, result.posted_content
      assert_equal %i[system user assistant], result.roles
    end
  end

  def test_the_empty_note_is_sent_back_when_the_clerk_asks_again
    cassette = YAML.load_file(File.expand_path("cassettes/accession_notice.yml", __dir__))
    interactions = cassette.fetch("http_interactions")
    first_request = interactions[0].dig("request", "body", "string")
    second_request = interactions[1].dig("request", "body", "string")
    first_response = interactions[0].dig("response", "body", "string")

    assert_includes first_request, '"max_tokens":64'
    refute_includes first_request, "reasoning_details"
    assert_includes first_response, '"content":null'
    assert_includes first_response, '"reasoning_tokens":64'
    refute_includes second_request, "max_tokens"
    assert_includes second_request, "reasoning_details"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/accession_notice.yml", __dir__))

    refute_match(/sk-or-/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
