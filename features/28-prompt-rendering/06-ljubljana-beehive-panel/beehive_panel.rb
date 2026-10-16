# frozen_string_literal: true

# Prompt rendering · 06 · Ljubljana beehive panel
#
# Teaches:
# - Prompt.roots is the search path. The scenario app/prompts is first.
# - An engine directory appended with << is searched next.
# - A host file at the same relative path overrides the engine.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module LjubljanaBeehivePanel
  class BeehivePanel
    ENGINE = File.expand_path("engine/app/prompts", __dir__)

    Result = Struct.new(:host_card, :engine_only, :without_engine_error, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        without_engine_error = nil
        begin
          RubyLLM.render_prompt("engine_only/card")
        rescue RubyLLM::PromptNotFoundError => raised
          without_engine_error = raised
        end

        RubyLLM::Prompt.roots << ENGINE
        host_card = RubyLLM.render_prompt("panel/instructions")
        engine_only = RubyLLM.render_prompt("engine_only/card")
        Result.new(
          host_card: host_card,
          engine_only: engine_only,
          without_engine_error: without_engine_error
        )
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
  Multivitamin::Cassettes.play(__dir__, "beehive_panel") do
    result = LjubljanaBeehivePanel::BeehivePanel.conduct
  end

  puts result.host_card
  puts result.engine_only
end
