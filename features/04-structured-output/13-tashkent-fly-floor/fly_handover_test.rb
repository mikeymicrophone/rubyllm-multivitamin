# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "yaml"
require_relative "fly_handover"

class TashkentFlyHandoverTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/fly_handover.yml", __dir__)

  def test_the_schema_stays_on_while_the_tool_and_the_judgment_do_their_jobs
    result = nil
    Multivitamin::Cassettes.play(__dir__, "fly_handover") do
      result = TashkentFlyFloor::FlyDesk.conduct
    end

    assert_equal TashkentFlyFloor::CostumeCabinetLatch.new.execute, result.tool_content
    assert_equal "shut", result.first.dig("fly_crew", "cabinet")
    assert_equal "Nigora", result.first.dig("fly_crew", "dresser")
    assert_equal "not posted", result.first["overture"]
    assert_equal "06:42", result.first.dig("curtain", "low_clock")
    assert_in_delta 0.4, result.first.dig("curtain", "low_height_m"), 0.001
    assert_equal "three-second blast", result.second["overture"]
    assert_equal result.first["companies"], result.second["companies"]
    assert_equal result.first["fly_crew"], result.second["fly_crew"]
    assert_equal %i[system user assistant tool assistant user assistant], result.roles
    assert_operator result.deck_clear, :<, 0.2
    assert_equal :neither, result.company
    assert_operator result.company_probabilities[:neither], :>, result.company_probabilities[:navoi]

    requests = request_bodies.map { |body| JSON.parse(body) }
    assert_equal "https://api.openai.com/v1/responses", request_uris[0]
    assert_equal "https://api.openai.com/v1/decisions", request_uris[3]
    assert_equal({ "type" => "function", "name" => "costume_cabinet_latch" }, requests[0]["tool_choice"])
    assert_nil requests[1]["tool_choice"]
    assert_nil requests[2]["tool_choice"]
    assert_equal "fly_handover", requests[0].dig("text", "format", "name")
    assert_equal "fly_handover", requests[2].dig("text", "format", "name")
    refute_includes JSON.generate(requests[0]["input"]), "shut"
    refute_includes JSON.generate(requests[0]["input"]), "Tonight"
    decision = requests[3]
    assert_equal "gpt-6-luna", decision["model"]
    assert_equal %w[predicate choice], decision["questions"].map { |question| question["type"] }
    assert_nil decision["text"]
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    interactions.map { |hit| hit.dig("request", "body", "string") }
  end

  def request_uris
    interactions.map { |hit| hit.dig("request", "uri") }
  end

  def interactions
    YAML.load_file(CASSETTE).fetch("http_interactions")
  end
end
