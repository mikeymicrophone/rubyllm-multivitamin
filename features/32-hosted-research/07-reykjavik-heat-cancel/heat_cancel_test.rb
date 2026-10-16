# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/research_assertions"
require_relative "heat_cancel"

class ReykjavikHeatCancelTest < Minitest::Test
  include Multivitamin::ResearchAssertions

  CASSETTE = File.expand_path("cassettes/heat_cancel.yml", __dir__)

  def test_heat_cancel_research_flow
    audit = Multivitamin::Cassettes.play(__dir__, "heat_cancel") { ReykjavikHeatCancel.conduct }
    assert_equal :pending, audit.dig(:before, :status)
    assert_equal :cancelled, audit.dig(:after, :status)
    assert audit.fetch(:cancelled)
    assert audit.fetch(:error).job.cancelled?
    assert_equal audit.dig(:before, :id), audit.dig(:after, :id)
    assert_equal "post", interactions.last.dig("request", "method")
    assert interactions.last.dig("request", "uri").end_with?("/cancel")
    assert_equal({}, requests.last)
  end

  def test_cassette_does_not_carry_a_live_key
    assert_research_credentials_filtered
  end

  def test_pending_cancellation_is_not_confirmed
    audit = Multivitamin::Cassettes.play(__dir__, "heat_pending") { ReykjavikHeatCancel.conduct }
    refute audit.fetch(:cancelled)
    assert_equal :pending, audit.dig(:after, :status)
    assert_nil audit.fetch(:error)
  end
end
