# frozen_string_literal: true

# Image generation · 08 · Ediz Hook bell buoy models
#
# Teaches:
# - model: selects gpt-image-1-mini or gpt-image-2.
# - Both ids are in the bundled registry, so assume_model_exists is off.
# - The cassette request names the id that was painted.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EdizHookBellBuoyModels
  # The buoy tender at Ediz Hook wants the same bell buoy painted on the
  # cheap mini model and on gpt-image-2, then files which id each plate used.
  class BuoyModels
    PROMPT = <<~TEXT.strip
      Bell buoy at the Ediz Hook tide race, Port Angeles harbor entrance.
      Red hull, last painted 12 March 2026, bell cage wet from the race.
      Looking from the hook toward the harbor. Documentary, no boats invented.
    TEXT

    Result = Struct.new(:mini, :full, keyword_init: true)

    def self.conduct
      configure
      mini = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)
      full = RubyLLM.paint(
        PROMPT,
        **Multivitamin::Models.image_paint(model: "gpt-image-2")
      )
      Result.new(mini: mini, full: full)
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
  Multivitamin::Cassettes.play(__dir__, "buoy_models") do
    result = EdizHookBellBuoyModels::BuoyModels.conduct
  end

  puts result.mini.model
  puts result.full.model
end
