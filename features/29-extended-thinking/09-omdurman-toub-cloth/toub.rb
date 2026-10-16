# frozen_string_literal: true

# Extended thinking · 09 · Omdurman toub cloth
#
# Teaches:
# - thinking stays with the provider that produced it.
# - with_model to OpenRouter drops the OpenAI signature on the next ask.
# - The earlier toub question stays on the transcript.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module OmdurmanToubCloth
  class ToubCloth
    INSTRUCTIONS = <<~TEXT.strip
      You are the toub clerk in Omdurman.
      Answer in one short sentence from the board only.
      The sentence must include the name Sittina and the time 16:10.
      Do not replace Sittina with a pronoun.
    TEXT

    BOARD = "Board: Sittina dyes lot OMD-2026-1016-T9 at 16:10. When does Sittina dye?"
    FOLLOW = "The stall asks again: what lot does Sittina dye?"

    Result = Struct.new(
      :opening,
      :follow_up,
      :opening_signature,
      :follow_model,
      :opening_model,
      keyword_init: true
    )

    def self.conduct
      configure_openai
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_REASONING, provider: :openai)
      chat.with_thinking(effort: :low, display: :summarized)
      chat.with_instructions(INSTRUCTIONS)
      opening = chat.ask(BOARD)

      configure_openrouter
      chat.with_model(
        Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_thinking(false)
      follow_up = chat.ask(FOLLOW)
      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        opening_signature: opening.thinking&.signature,
        follow_model: follow_up.model,
        opening_model: opening.model
      )
    end

    def self.configure_openai
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end

    def self.configure_openrouter
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "toub") do
    result = OmdurmanToubCloth::ToubCloth.conduct
  end

  puts result.opening
  puts result.follow_up
end
