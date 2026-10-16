# frozen_string_literal: true

# Image generation · 07 · Rila hearth sizes
#
# Teaches:
# - Two paint calls with two sizes produce two request bodies.
# - 1024x1024 is square. 1536x1024 is the landscape size this model lists.
# - Each call is its own images/generations interaction.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RilaHearthSizes
  # The kitchen at Rila Monastery wants a square plate of the hearth and
  # a landscape plate of the same hearth against the courtyard colonnade.
  class HearthSizes
    SQUARE = <<~TEXT.strip
      Square plate of the kitchen hearth at Rila Monastery, hanging chain and copper cauldron,
      one bay west of the courtyard well.
      Six links above the grate, andirons taut, documentary.
    TEXT

    LANDSCAPE = <<~TEXT.strip
      Landscape plate of the same Rila kitchen hearth against the courtyard colonnade,
      Rila Monastery, Rilska valley, afternoon light from the west.
      The hearth and the colonnade in one frame. Documentary.
    TEXT

    Result = Struct.new(:square, :landscape, keyword_init: true)

    def self.conduct
      configure
      square = RubyLLM.paint(SQUARE, **Multivitamin::Models.image_paint(size: "1024x1024"))
      landscape = RubyLLM.paint(LANDSCAPE, **Multivitamin::Models.image_paint(size: "1536x1024"))
      Result.new(square: square, landscape: landscape)
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "hearth_sizes") do
    result = RilaHearthSizes::HearthSizes.conduct
  end

  puts result.square.model
  puts result.landscape.model
end
