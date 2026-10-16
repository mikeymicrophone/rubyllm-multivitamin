# frozen_string_literal: true

# Extended thinking · 08 · Khartoum hibiscus karkade
#
# Teaches:
# - with_thinking(false) on Nemotron sends reasoning.enabled false.
# - thinking.text on the brief is nil.
# - The karkade card is still answered.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KhartoumHibiscusKarkade
  class Karkade
    INSTRUCTIONS = <<~TEXT.strip
      You are the karkade clerk in Khartoum.
      Answer in one short sentence from the board only.
      Name Maha and 05:45.
    TEXT

    BOARD = "Board: Maha steeps lot KRT-2026-1016-H1 at 05:45. When does Maha steep?"

    Result = Struct.new(:brief, :thinking_text, :enabled, keyword_init: true)

    def self.conduct
      configure
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
      chat.with_thinking(false)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(BOARD)
      Result.new(
        brief: brief.content,
        thinking_text: brief.thinking&.text,
        enabled: chat.thinking
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
  Multivitamin::Cassettes.play(__dir__, "karkade") do
    result = KhartoumHibiscusKarkade::Karkade.conduct
  end

  puts result.brief
  puts "thinking=#{result.thinking_text.inspect} enabled=#{result.enabled.inspect}"
end
