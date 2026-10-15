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

    clipped_text = result.clipped_content.to_s.strip
    short_note = clipped_text.empty? || result.clipped_max_tokens || clipped_text.length < SingaporeAccession::AccessionNotice::SHORT_LENGTH
    assert_equal true, result.asked_again
    assert_equal short_note, result.asked_again
    assert_equal 200, result.clipped_status
    assert_equal 200, result.posted_status

    assert_includes result.posted_content, "18465"
    assert_includes result.posted_content, "DH"
    assert_match(/300/, result.posted_content)

    assert_operator clipped_text.length, :<, result.posted_content.to_s.length
    assert_equal %i[system user assistant user assistant], result.roles
  end

  def test_the_capped_request_is_followed_by_an_uncapped_ask
    cassette = YAML.load_file(File.expand_path("cassettes/accession_notice.yml", __dir__))
    interactions = cassette.fetch("http_interactions")
    first_request = interactions[0].dig("request", "body", "string")
    second_request = interactions[1].dig("request", "body", "string")

    clip = SingaporeAccession::AccessionNotice::CLIP
    assert_includes first_request, "\"max_output_tokens\":#{clip}"
    refute_includes second_request, "max_output_tokens"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/accession_notice.yml", __dir__))

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
