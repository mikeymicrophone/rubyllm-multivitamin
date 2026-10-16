# frozen_string_literal: true

# Prompt rendering · 05 · Taroudant tadelakt plaster
#
# Teaches:
# - render "tone" looks next to the current prompt for _tone.txt.erb.
# - Partials receive only the locals you pass.
# - There is no cassette file.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module TaroudantTadelaktPlaster
  class TadelaktPlaster
    Result = Struct.new(:card, :tone_only, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        card = RubyLLM.render_prompt(
          "tadelakt/instructions",
          plasterer: "Fatima",
          lot: "TAR-2026-1016-T3"
        )
        tone_only = RubyLLM.render_prompt("tadelakt/_tone", plasterer: "Fatima")
        Result.new(card: card, tone_only: tone_only)
      end
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "tadelakt") do
    result = TaroudantTadelaktPlaster::TadelaktPlaster.conduct
  end

  puts result.card
end
