# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "publish_latch"

class PublishLatchTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/publish_latch.yml", __dir__)

  def test_the_notice_waits_on_the_dockmaster_then_posts
    result = nil
    Multivitamin::Cassettes.play(__dir__, "publish_latch") do
      result = PortLudlowPublishLatch::Dockmaster.conduct
    end

    assert result.awaiting
    assert result.waiting
    refute result.posted_before_approve
    assert_equal "publish_watch_notice", result.pending_name
    assert_equal :assistant, result.parked_role
    assert result.posted_after
    assert_equal PortLudlowPublishLatch::PublishWatchNotice::NOTICE, result.tool_content
    assert_includes result.answer, "Marrowstone"
    assert_includes result.answer, "21:00"
    assert_equal %i[system user assistant tool assistant], result.roles

    bodies = request_bodies
    assert_includes bodies.fetch(0), '"name":"publish_watch_notice"'
    assert_includes bodies.fetch(0), '"tool_choice":{"type":"function","name":"publish_watch_notice"}'
    refute_includes bodies.fetch(0), "21:00"
    refute_includes bodies.fetch(0), "inner float"
    assert_includes bodies.last, "21:00"
    refute_includes bodies.last, "tool_choice"
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
    refute_includes cassette, "Bearer sk-"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string")
    end
  end
end
