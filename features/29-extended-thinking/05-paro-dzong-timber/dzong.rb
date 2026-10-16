# frozen_string_literal: true

# Extended thinking · 05 · Paro dzong timber
#
# Teaches:
# - display: :omitted keeps thinking on without a summary.
# - thinking.text is nil. The signature may still arrive.
# - The wire has effort and no summary: auto.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ParoDzongTimber
  class DzongTimber
    INSTRUCTIONS = <<~TEXT.strip
      You are the dzong timber clerk in Paro.
      Answer in one short sentence from the board only.
      The sentence must include the name Tashi and the time 06:50.
      Do not replace Tashi with a pronoun.
    TEXT

    BOARD = "Board: Tashi marks beam PAR-2026-1016-Z6 at 06:50. When does Tashi mark?"

    Result = Struct.new(:brief, :thinking_text, :signature, :display, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_thinking(effort: :low, display: :omitted)
      chat.with_instructions(INSTRUCTIONS)
      brief = chat.ask(BOARD)
      Result.new(
        brief: brief.content,
        thinking_text: brief.thinking&.text,
        signature: brief.thinking&.signature,
        display: chat.thinking
      )
    end

    def self.open_chat
      RubyLLM.chat(model: Multivitamin::Models::OPENAI_REASONING, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "dzong") do
    result = ParoDzongTimber::DzongTimber.conduct
  end

  puts result.brief
  puts "text=#{result.thinking_text.inspect} sig=#{result.signature.to_s.bytesize}"
end
