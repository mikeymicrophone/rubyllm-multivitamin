# frozen_string_literal: true

# Extended thinking · 04 · Aizawl puan cloth
#
# Teaches:
# - display: :summarized sends reasoning.summary auto.
# - gpt-5-nano may still return an empty summary, so thinking.text is nil.
# - thinking.signature is the encrypted block.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AizawlPuanCloth
  class PuanCloth
    INSTRUCTIONS = <<~TEXT.strip
      You are the puan clerk in Aizawl.
      Answer in one short sentence from the board only.
      The sentence must include the name Lalrin and the time 10:15.
      Do not replace Lalrin with a pronoun.
    TEXT

    BOARD = "Board: Lalrin weaves puan AIZ-2026-1016-P4 at 10:15. When does Lalrin weave?"

    Result = Struct.new(:brief, :thinking_text, :signature, :roles, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_thinking(effort: :medium, display: :summarized)
      chat.with_instructions(INSTRUCTIONS)
      brief = chat.ask(BOARD)
      Result.new(
        brief: brief.content,
        thinking_text: brief.thinking&.text,
        signature: brief.thinking&.signature,
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "puan") do
    result = AizawlPuanCloth::PuanCloth.conduct
  end

  puts result.brief
  puts "thinking=#{result.thinking_text.to_s.bytesize} sig=#{result.signature.to_s.bytesize}"
end
