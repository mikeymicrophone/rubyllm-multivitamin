# frozen_string_literal: true

require "minitest/autorun"
require_relative "toquilla_brim"

class GuayaquilToquillaBrimTest < Minitest::Test
  def test_the_helper_defines_one_method_per_case
    klass = Class.new do
      extend RubyLLM::Evaluation::Minitest
      evaluates GuayaquilToquillaBrim::BrimWidth
    end

    names = klass.instance_methods(false).map(&:to_s).grep(/\Atest_/)
    assert_equal 1, names.size
    assert_match(/brim_width/, names.first)
  end

  def test_the_brim_case_passes
    report = nil
    Multivitamin::Cassettes.play(__dir__, "toquilla_brim") do
      report = GuayaquilToquillaBrim::BrimWidth.conduct
    end

    assert_equal true, report.passed?
    assert_match(/12/, report.trials.first.output.to_s)
    assert_match(/Dolores/, report.trials.first.output.to_s)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(File.expand_path("cassettes/toquilla_brim.yml", __dir__))

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    refute_match(/sk-(?:proj-)?[A-Za-z0-9_\-]{12,}/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
