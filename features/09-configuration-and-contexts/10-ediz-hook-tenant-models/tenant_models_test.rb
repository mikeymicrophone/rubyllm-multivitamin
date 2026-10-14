# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "tenant_models"

class EdizHookTenantModelsTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/tenant_models.yml", __dir__)

  def test_each_tenant_default_model_is_a_different_slug
    result = nil
    Multivitamin::Cassettes.play(__dir__, "tenant_models") do
      result = EdizHookTenantModels::TenantModels.conduct
    end

    assert_includes result.hook_reply, "11.8"
    assert_includes result.loft_reply, "36"
    assert_equal result.hook_default, result.hook_model_id
    assert_equal result.loft_default, result.loft_model_id
    refute_equal result.hook_model_id, result.loft_model_id
    refute_equal result.hook_default, result.global_default

    bodies = request_bodies
    assert_includes bodies.fetch(0), "\"model\":\"#{result.hook_default}\""
    assert_includes bodies.fetch(1), "\"model\":\"#{result.loft_default}\""
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end

  def request_bodies
    YAML.load_file(CASSETTE).fetch("http_interactions").map do |interaction|
      interaction.dig("request", "body", "string").to_s
    end
  end
end
