# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "papyrus_reject"

class PapyrusRejectTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/papyrus_reject.yml", __dir__)

  def test_strict_mode_rejects_a_missing_required_property_then_null_is_allowed
    result = nil
    Multivitamin::Cassettes.play(__dir__, "papyrus_reject") do
      result = AlexandriaPapyrusReject::NoticeDesk.conduct
    end

    assert_equal RubyLLM::BadRequestError, result.rejection_class
    assert_includes result.rejection_message, "PapyrusCorrection"
    assert_includes result.rejection_message, "findspot"
    assert_equal "Zenon", result.parsed["shelfmark"]
    assert_equal "1842", result.parsed["notice"]
    assert_nil result.parsed["findspot"]
    assert_equal result.parsed, AlexandriaPapyrusReject::NoticeDesk.accept_notice(result.parsed)
    assert_equal :stop, result.finish

    broken = JSON.parse(request_bodies.fetch(0))
    repaired = JSON.parse(request_bodies.fetch(1))
    assert_equal 400, statuses.fetch(0)
    assert_equal 200, statuses.fetch(1)
    assert_equal true, broken.dig("text", "format", "strict")
    refute_includes broken.dig("text", "format", "schema", "required"), "findspot"
    assert_equal true, repaired.dig("text", "format", "strict")
    assert_includes repaired.dig("text", "format", "schema", "required"), "findspot"
    assert_equal [{ "type" => "string" }, { "type" => "null" }],
                 repaired.dig("text", "format", "schema", "properties", "findspot", "anyOf")
  end

  def test_a_notice_without_a_shelfmark_is_refused_before_it_is_posted
    error = assert_raises(AlexandriaPapyrusReject::MissingShelfmark) do
      AlexandriaPapyrusReject::NoticeDesk.accept_notice("notice" => "1842")
    end

    assert_includes error.message, "shelfmark"
  end

  def test_the_registry_splits_structured_output_from_judgment
    AlexandriaPapyrusReject::NoticeDesk.configure
    assert_equal "jev-latest", RubyLLM.config.default_judgment_model
    mini = RubyLLM.models.find("gpt-4.1-mini", provider: :openai)
    luna = RubyLLM.models.find(Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai)
    whisper = RubyLLM.models.find("whisper-1", provider: :openai)

    assert mini.supports?(:structured_output)
    refute mini.supports?(:judgment)
    assert luna.supports?(:structured_output)
    assert luna.supports?(:judgment)
    refute whisper.supports?(:structured_output)
    refute whisper.supports?(:judgment)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |hit| hit.dig("request", "body", "string") }
  end

  def statuses
    interactions.map { |hit| hit.dig("response", "status", "code") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
