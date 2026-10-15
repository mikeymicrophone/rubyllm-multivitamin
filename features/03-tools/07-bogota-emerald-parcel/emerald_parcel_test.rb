# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "emerald_parcel"

class EmeraldParcelTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/emerald_parcel.yml", __dir__)

  def test_a_miss_comes_back_as_json_and_the_clerk_tries_again
    result = nil
    Multivitamin::Cassettes.play(__dir__, "emerald_parcel") do
      result = BogotaEmeraldParcel::ParcelRound.conduct
    end

    assert_equal 2, result.tool_contents.size
    miss = JSON.parse(result.tool_contents.fetch(0))
    assert_includes miss.fetch("error"), "CO-17"
    assert_includes miss.fetch("error"), "CO-4"
    assert_equal BogotaEmeraldParcel::EmeraldParcel::CARDS.fetch("CO-4"), result.tool_contents.fetch(1)
    assert_includes result.answer, "12.6"
    assert_equal %i[system user assistant tool assistant tool assistant], result.roles

    bodies = YAML.load_file(CASSETTE).fetch("http_interactions").map { |interaction| interaction.dig("request", "body", "string") }
    assert_includes bodies.fetch(0), '"tool_choice":"required"'
    refute_includes bodies.fetch(0), "12.6"
    refute_includes bodies.fetch(1), '"tool_choice"'
    assert_includes bodies.fetch(1), "CO-17"
    refute_includes bodies.fetch(1), "12.6"
    assert_includes bodies.fetch(2), "12.6"
  end

  def test_a_missing_parcel_returns_an_error_hash_and_a_known_parcel_returns_a_string
    tool = BogotaEmeraldParcel::EmeraldParcel.new
    miss = tool.execute(parcel: "CO-17")

    assert_kind_of Hash, miss
    assert_includes miss.fetch(:error), "CO-4"
    assert_kind_of String, tool.execute(parcel: "co-4")
    assert_includes tool.class.split_result(miss).first, '"error"'
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end
end
