# frozen_string_literal: true

# Extended thinking · 02 · Ouagadougou bronze lost-wax
#
# Teaches:
# - with_thinking(effort: :low) sends reasoning.effort low on gpt-5-nano.
# - gpt-5-nano does not take temperature.
# - thinking.text stays nil unless display: :summarized.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module OuagadougouBronzeLostWax
  class BronzeLostWax
    INSTRUCTIONS = <<~TEXT.strip
      You are the bronze clerk in Ouagadougou.
      Answer in one short sentence from the board only.
      The sentence must include the name Aminata and the time 07:30.
      Do not replace Aminata with a pronoun.
    TEXT

    BOARD = "Board: Aminata pours lot OUA-2026-1016-B7 at 07:30. When does Aminata pour?"

    Result = Struct.new(:brief, :thinking_text, :effort, :roles, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_thinking(effort: :low)
      chat.with_instructions(INSTRUCTIONS)
      brief = chat.ask(BOARD)
      Result.new(
        brief: brief.content,
        thinking_text: brief.thinking&.text,
        effort: chat.thinking,
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
  Multivitamin::Cassettes.play(__dir__, "bronze") do
    result = OuagadougouBronzeLostWax::BronzeLostWax.conduct
  end

  puts result.brief
  puts "effort=#{result.effort.inspect} thinking=#{result.thinking_text.inspect}"
end
