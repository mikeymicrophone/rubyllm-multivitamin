# frozen_string_literal: true

require "minitest/autorun"
require_relative "fab_logger"

class KaohsiungFabLoggerTest < Minitest::Test
  CASSETTE = File.expand_path("cassettes/fab_logger.yml", __dir__)

  def test_ruby_llm_logger_stays_memoized_until_cleared
    first = RubyLLM.logger
    other = Logger.new(File::NULL)
    RubyLLM.configure { |config| config.logger = other }
    assert_same first, RubyLLM.logger
    RubyLLM.instance_variable_set(:@logger, nil)
    refute_same first, RubyLLM.logger
  ensure
    RubyLLM.instance_variable_set(:@logger, nil)
  end

  def test_the_fab_logger_receives_the_uptime_round_request
    result = nil
    Multivitamin::Cassettes.play(__dir__, "fab_logger") do
      result = KaohsiungFabLogger::FabLogger.conduct
    end

    assert_includes result.round, "15"
    assert_includes result.round, "99.4"
    assert result.after_clear_uses_station_logger
    assert_match(/POST/i, result.log_text)
    assert_match(/chat\/completions/, result.log_text)
    refute_match(/RUBYLLM_DEBUG/, result.log_text)
  end

  def test_cassette_does_not_carry_a_live_key
    cassette = File.read(CASSETTE)

    refute_match(/sk-or-v1-[A-Za-z0-9_\-]{8,}/, cassette)
    assert_includes cassette, "<OPENROUTER_API_KEY>"
  end
end
