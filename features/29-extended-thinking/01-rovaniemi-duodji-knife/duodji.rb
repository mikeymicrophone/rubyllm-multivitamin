# frozen_string_literal: true

# Extended thinking · 01 · Rovaniemi duodji knife
#
# Teaches:
# - with_thinking with no options uses the model's registered controls.
# - On Nemotron that is a toggle: the wire sends reasoning.enabled true.
# - thinking.text is the spoken reasoning, not the brief.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RovaniemiDuodjiKnife
  class DuodjiKnife
    INSTRUCTIONS = <<~TEXT.strip
      You are the duodji clerk in Rovaniemi.
      Answer in one short sentence from the board only.
      Name Aila and 08:00.
    TEXT

    BOARD = "Board: Aila hones knife ROV-2026-1016-D3 at 08:00. When does Aila hone?"

    Result = Struct.new(
      :brief,
      :thinking_text,
      :enabled,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
      chat.with_thinking
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(BOARD)
      Result.new(
        brief: brief.content,
        thinking_text: brief.thinking&.text,
        enabled: chat.thinking,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
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
  Multivitamin::Cassettes.play(__dir__, "duodji") do
    result = RovaniemiDuodjiKnife::DuodjiKnife.conduct
  end

  puts result.brief
  puts "thinking=#{result.thinking_text.to_s.bytesize} enabled=#{result.enabled.inspect}"
end
