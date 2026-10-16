# frozen_string_literal: true

# Prompt rendering · 12 · Chichicastenango huipil
#
# Teaches:
# - local_assigns reads an optional local without raising.
# - A missing weaver name still renders.
# - There is no cassette file.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module ChichicastenangoHuipil
  class Huipil
    Result = Struct.new(:with_weaver, :without_weaver, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        with_weaver = RubyLLM.render_prompt(
          "huipil/tone",
          weaver: "Ixchel",
          lot: "CHC-2026-1016-H2"
        )
        without_weaver = RubyLLM.render_prompt("huipil/tone", lot: "CHC-2026-1016-H2")
        Result.new(with_weaver: with_weaver, without_weaver: without_weaver)
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
  Multivitamin::Cassettes.play(__dir__, "huipil") do
    result = ChichicastenangoHuipil::Huipil.conduct
  end

  puts result.with_weaver
  puts result.without_weaver
end
