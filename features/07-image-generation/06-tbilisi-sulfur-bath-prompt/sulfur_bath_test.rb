# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "sulfur_bath"

class TbilisiSulfurBathPromptTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/sulfur_bath.yml", __dir__)

  def test_revised_prompt_is_nil_and_the_wire_keeps_the_desk_copy
    result = nil
    Multivitamin::Cassettes.play(__dir__, "sulfur_bath") do
      result = TbilisiSulfurBathPrompt::SulfurBath.conduct
    end

    assert_nil result.revised_prompt
    assert_equal "gpt-image-1-mini", result.model
    assert_includes result.original_prompt, "Bath 4"
    assert_includes result.original_prompt, "Abanotubani"

    request = request_body
    assert_includes request, "Bath 4"
    assert_includes request, "Abanotubani"
    refute_includes response_body, "revised_prompt"
  end

  def test_cassette_does_not_carry_a_live_key
    skip "cassette not recorded yet" unless File.exist?(CASSETTE)
    cassette = File.read(CASSETTE)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("request", "body", "string")
  end

  def response_body
    YAML.load_file(CASSETTE).fetch("http_interactions").fetch(0).dig("response", "body", "string")
  end
end
