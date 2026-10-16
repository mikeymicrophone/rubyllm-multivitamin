# frozen_string_literal: true

require "minitest/autorun"
require_relative "huipil"

class ChichicastenangoHuipilOptionalLocalTest < Minitest::Test
  def test_the_weaver_local_is_optional
    result = nil
    Multivitamin::Cassettes.play(__dir__, "huipil") do
      result = ChichicastenangoHuipil::Huipil.conduct
    end

    assert_includes result.with_weaver, "with Ixchel"
    assert_includes result.with_weaver, "CHC-2026-1016-H2"
    refute_includes result.without_weaver, "Ixchel"
    assert_includes result.without_weaver, "Be warm and direct."
    assert_includes result.without_weaver, "CHC-2026-1016-H2"
    refute File.exist?(File.expand_path("cassettes/huipil.yml", __dir__))
  end
end
