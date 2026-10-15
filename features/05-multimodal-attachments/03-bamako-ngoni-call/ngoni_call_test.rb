# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "ngoni_call"

class NgoniCallTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/ngoni_call.yml", __dir__)

  def test_the_recording_names_the_takes
    result = nil
    Multivitamin::Cassettes.play(__dir__, "ngoni_call") do
      result = BamakoNgoniCall::NgoniCall.conduct
    end

    assert_includes result.log_line, "BKO"
    assert_match(/two|2/i, result.log_line)
    assert_match(/quarter/i, result.log_line)
    assert_equal :audio, result.attachment_type
    assert_equal %i[system user assistant], result.roles
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_nil result.cost

    request = request_bodies.fetch(0)
    response = response_bodies.fetch(0)
    assert_includes request, '"model":"gpt-audio-mini"'
    assert_includes request, '"type":"input_audio"'
    assert_includes request, '"format":"mp3"'
    assert_includes response, '"audio_tokens"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |interaction| utf8(interaction.dig("request", "body", "string")) }
  end

  def response_bodies
    interactions.map { |interaction| utf8(interaction.dig("response", "body", "string")) }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end

  def utf8(body)
    body.to_s.dup.force_encoding(Encoding::UTF_8)
  end
end
