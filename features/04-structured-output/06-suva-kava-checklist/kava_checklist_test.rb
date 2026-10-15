# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "kava_checklist"

class KavaChecklistTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/kava_checklist.yml", __dir__)

  def test_the_checklist_uses_the_name_set_on_the_hash
    result = nil
    Multivitamin::Cassettes.play(__dir__, "kava_checklist") do
      result = SuvaKavaChecklist::ServingChecklist.conduct
    end

    assert_includes result.parsed["circle"], "Vunisa"
    assert_equal "Suva", result.parsed["vale"]
    assert_equal true, result.parsed["tanoa_ready"]
    assert_equal "east", result.parsed["herald_side"]
    assert_equal ["water drawn", "strainer set"], result.parsed["steps"].map { |step| step["item"] }
    assert result.parsed["steps"].all? { |step| step["ready"] == true }
    assert_equal %i[system user assistant], result.roles
    assert_operator result.cost, :>, 0

    format = JSON.parse(request_bodies.fetch(0)).dig("text", "format")
    assert_equal "KavaServingChecklist", format["name"]
    refute_equal "response", format["name"]
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit| hit.dig("request", "body", "string") }
  end
end
