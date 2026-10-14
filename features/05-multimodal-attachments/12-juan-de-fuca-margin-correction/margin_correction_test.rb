# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "yaml"
require_relative "margin_correction"

class MarginCorrectionTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/margin_correction.yml", __dir__)

  def test_the_extensionless_scan_is_still_a_png
    result = nil
    Multivitamin::Cassettes.play(__dir__, "margin_correction") do
      result = JuanDeFucaMarginCorrection::MarginCorrection.conduct
    end

    assert_equal "image/png", result.mime_type
    assert_nil result.extension
    assert_equal :image, result.attachment_type
    assert_includes result.notice, "18400"
    assert_includes result.notice, "DH"
    assert_includes result.notice, "0.4"
    assert_equal :stop, result.finish
    assert_operator result.cost, :>, 0

    request = request_bodies.fetch(0)
    assert_includes request, "data:image/png;base64,"
    assert_includes request, '"type":"input_image"'
    refute_includes request, "application/octet-stream"
  end

  def test_a_bin_name_does_not_hide_png_bytes
    copy = File.join(Dir.tmpdir, "juan-de-fuca-scan.bin")
    File.binwrite(copy, File.binread(JuanDeFucaMarginCorrection::MarginCorrection::SCAN))
    labeled = RubyLLM::Attachment.new(copy)

    assert_equal "bin", labeled.extension
    assert_equal "image/png", labeled.mime_type
    assert_equal :image, labeled.type
  ensure
    File.delete(copy) if copy && File.exist?(copy)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s.dup.force_encoding(Encoding::UTF_8)
    end
  end
end
