# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "dry_dock_base"

class BremertonOpenrouterBaseTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/dry_dock_base.yml", __dir__)

  def test_the_yard_context_uses_the_openrouter_base_and_leaves_proxy_unset
    result = nil
    Multivitamin::Cassettes.play(__dir__, "dry_dock_base") do
      result = BremertonOpenrouterBase::DryDockBase.conduct
    end

    assert_includes result.flood, "Cape Flattery"
    assert_includes result.flood, "09:15"
    assert_equal BremertonOpenrouterBase::DryDockBase::OPENROUTER_BASE, result.context_base
    assert_nil result.global_base
    assert_nil result.context_proxy
    assert_nil result.global_proxy
    assert_equal File.expand_path("tmp/ruby_llm_models.json", __dir__), result.registry_file
    refute_equal result.registry_file, RubyLLM.config.model_registry_file

    uri = YAML.load_file(CASSETTE).dig("http_interactions", 0, "request", "uri")
    assert_equal "#{BremertonOpenrouterBase::DryDockBase::OPENROUTER_BASE}/chat/completions", uri
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
