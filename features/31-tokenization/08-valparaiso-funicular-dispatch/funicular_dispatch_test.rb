# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../support/cassette_assertions"
require_relative "funicular_dispatch"

class ValparaisoFunicularDispatchTest < Minitest::Test
  include Multivitamin::CassetteAssertions

  def test_plain_tokenization_leaves_the_dispatch_instructions_out_of_the_payload
    result = play
    request = requests.fetch(0)

    assert_operator result.fetch(:plain), :>, 0
    assert_equal %i[system user], result.fetch(:roles)
    refute result.fetch(:complete)
    assert_equal %w[model text], request.keys.sort
    assert_equal result.fetch(:bulletin), request.fetch("text")
    assert_includes request.fetch("text"), "Camila opens gate VAP-2 at 09:10"
    assert_includes request.fetch("text"), "Tomás holds cabin VAP-7"
    refute_includes request.fetch("text"), "Name only the cabin"
    refute "dispatch board".respond_to?(:dispatch_lines)
  end

  def test_cassette_has_no_live_key
    assert_cassette_sanitized(__dir__, "funicular_dispatch", key: "XAI_API_KEY")
  end

  def play
    Multivitamin::Cassettes.play(__dir__, "funicular_dispatch") { ValparaisoFunicularDispatch.conduct }
  end

  def requests = cassette_requests(__dir__, "funicular_dispatch")
  def interactions = cassette_interactions(__dir__, "funicular_dispatch")
end
