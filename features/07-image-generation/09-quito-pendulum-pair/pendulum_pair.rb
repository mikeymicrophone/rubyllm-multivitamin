# frozen_string_literal: true

# Image generation · 09 · Quito pendulum pair
#
# Teaches:
# - count: 2 sends n: 2 and returns an Array of Image.
# - Usage lives on the first image. The second image's tokens.output is nil.
# - A count of 1 (the default) returns a single Image, not a one-element array.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module QuitoPendulumPair
  # The clerk at Ciudad Mitad del Mundo wants two plates of the Foucault
  # pendulum, one for the noon round and one for the relief's kit.
  class PendulumPair
    PROMPT = <<~TEXT.strip
      Foucault pendulum in the equatorial hall at Ciudad Mitad del Mundo, Quito.
      Bob at the noon mark, 16.4 s period, brass disk, lamp over the log.
      Two plates from one request for the noon round and the relief kit. Documentary.
    TEXT

    Result = Struct.new(
      :images,
      :first_output_tokens,
      :second_output_tokens,
      keyword_init: true
    )

    def self.conduct
      configure
      images = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint(count: 2))

      Result.new(
        images: images,
        first_output_tokens: images.fetch(0).tokens.output,
        second_output_tokens: images.fetch(1).tokens.output
      )
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
  Multivitamin::Cassettes.play(__dir__, "pendulum_pair") do
    result = QuitoPendulumPair::PendulumPair.conduct
  end

  puts result.images.length
  puts result.first_output_tokens
  puts result.second_output_tokens.inspect
end
