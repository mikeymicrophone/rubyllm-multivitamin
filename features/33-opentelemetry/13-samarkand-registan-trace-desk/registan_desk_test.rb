# frozen_string_literal: true

require "minitest/autorun"
require_relative "registan_desk"

class SamarkandRegistanTraceDeskTest < Minitest::Test
  def test_registan_desk_trace
    capture = Multivitamin::Cassettes.play(__dir__, "registan_desk") do
      SamarkandRegistanTraceDesk.conduct
    end

    first, revised = capture.value.fetch(:cards)
    assert_equal "Dilshod", first.fetch("keeper")
    assert_equal 8, first.fetch("tile_crates")
    assert_equal "08:25", first.fetch("unload")
    assert_equal first.slice("keeper", "tile_crates"), revised.slice("keeper", "tile_crates")
    assert_equal "08:50", revised.fetch("unload")
    assert_equal %i[system user assistant tool assistant user assistant], capture.value.fetch(:roles)
    assert_equal 7, capture.spans.size
    assert_equal 1, capture.spans.map(&:trace_id).uniq.size
    chats = capture.spans.select { |span| span.kind == :client }
    assert_equal 3, chats.size
    assert chats.all? { |span| span.attributes.fetch("gen_ai.output.type") == "json" }
    assert_equal capture.value.fetch(:tokens).output, chats.sum { |span| span.attributes.fetch("gen_ai.usage.output_tokens") }
    tool = capture.spans.find { |span| span.name == "execute_tool tile_cart" }
    step = capture.spans.find { |span| span.name == "ruby_llm.workflow_step Read tile cart" }
    assert_equal step.span_id, tool.parent_span_id
  end

  def test_cassette_has_only_filtered_credentials
    cassette = File.binread(File.expand_path("cassettes/registan_desk.yml", __dir__))
    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
