# frozen_string_literal: true

# Audio transcription · 04 · Freshwater Bay vocabulary prompt
#
# Teaches:
# - prompt: sends station vocabulary on the transcription request.
# - The hint is for names the tape already speaks: Dungeness, kelp ledge,
#   MLLW, Fresnel.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FreshwaterBayVocabulary
  # The mate at Freshwater Bay files a Dungeness Spit kelp-ledge tape.
  # The prompt lists the spellings the chart desk already uses.
  class VocabularyPrompt
    RECORDING = File.expand_path("freshwater-bay-vocab.mp3", __dir__)
    VOCABULARY = "Dungeness Spit, kelp ledge, MLLW, Fresnel."

    Result = Struct.new(:text, :prompt, :model, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(
        RECORDING,
        **Multivitamin::Models.transcribe,
        prompt: VOCABULARY
      )

      Result.new(text: tape.text, prompt: VOCABULARY, model: tape.model)
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
  Multivitamin::Cassettes.play(__dir__, "freshwater_vocab") do
    result = FreshwaterBayVocabulary::VocabularyPrompt.conduct
  end

  puts result.model
  puts result.text
end
