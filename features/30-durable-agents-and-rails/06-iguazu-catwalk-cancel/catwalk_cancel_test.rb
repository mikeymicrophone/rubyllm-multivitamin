# frozen_string_literal: true

require "minitest/autorun"
require_relative "catwalk_cancel"

class IguazuCatwalkCancelTest < Minitest::Test
  def test_catwalk_worker_observes_remote_cancel
    result = Multivitamin::Cassettes.play(__dir__, "catwalk_cancel") { IguazuCatwalkCancel.conduct }

    assert result.fetch(:interrupted)
    assert_equal ["Garganta footbridge closed. "], result.fetch(:spoken) unless Multivitamin::Cassettes.live?
    assert_equal %i[system user], result.fetch(:roles)
    assert_equal 0, result.fetch(:assistants)
  end

  def test_cassette_has_no_live_key
    cassette = File.binread(File.join(__dir__, "cassettes/catwalk_cancel.yml"))
    refute_match(/sk-/, cassette)
    assert_includes cassette, "<OPENAI_API_KEY>"
  end
end
