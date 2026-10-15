# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "pina_invoice"

class PinaInvoiceTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/pina_invoice.yml", __dir__)

  def test_the_second_ask_sends_the_invoice_again
    result = nil
    Multivitamin::Cassettes.play(__dir__, "pina_invoice") do
      result = CebuPinaInvoice::PinaInvoice.conduct
    end

    assert_includes result.bolt, "9"
    assert_includes result.bolt, "27"
    assert_includes result.metres, "4"
    assert_equal [1, 0], result.attachment_counts
    assert_operator result.byte_size, :<, RubyLLM::Protocols::Responses::Chat::OPENAI_INLINE_FILE_LIMIT
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    bodies = request_bodies
    assert_equal 2, bodies.length
    bodies.each do |body|
      assert_includes body, '"file_data":"data:application/pdf;base64,'
      refute_includes body, "file_id"
    end
    assert_operator bodies.fetch(1).bytesize, :>, bodies.fetch(0).bytesize
    assert_equal ["https://api.openai.com/v1/responses", "https://api.openai.com/v1/responses"], request_uris
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |interaction| interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8) }
  end

  def request_uris
    interactions.map { |interaction| interaction.dig("request", "uri") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
