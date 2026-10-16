# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "jacquard_orders"

class LyonJacquardOrdersTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/jacquard_orders.yml", __dir__)

  def test_standing_orders_are_the_first_system_message
    result = nil
    Multivitamin::Cassettes.play(__dir__, "jacquard_orders") do
      result = LyonJacquardOrders::JacquardOrders.conduct
    end

    assert_equal :system, result.first_role
    assert_includes result.first_content, "warp-weight standing orders"
    assert_equal %i[system user assistant], result.roles
    assert_match(/\A\s*Yes\b/i, result.brief.to_s)
    assert_includes result.brief, "Amélie"
    assert_includes result.brief, "4.5"
    assert_includes result.brief, "2.6"
    assert_equal :stop, result.finish
    assert_operator result.input_tokens, :>, 0
    assert_operator result.cost, :>, 0
  end

  def test_cassette_carries_the_standing_orders
    body = request_bodies.fetch(0)

    assert_includes body, "warp-weight standing orders"
    assert_includes body, "Amélie"
    assert(body.include?('"instructions":') || body.include?('"role":"system"'))
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.binread(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map { |hit|
      hit.dig("request", "body", "string")
    }
  end
end
