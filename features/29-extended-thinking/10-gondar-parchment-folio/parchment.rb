# frozen_string_literal: true

# Extended thinking · 10 · Gondar parchment folio
#
# Teaches:
# - tokens.thinking is an Integer on gpt-5-nano.
# - tokens.output already includes that work; do not add them.
# - cost.thinking is nil when the registry has no separate reasoning price.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module GondarParchmentFolio
  class ParchmentFolio
    INSTRUCTIONS = <<~TEXT.strip
      You are the parchment clerk in Gondar.
      Answer in one short sentence from the board only.
      Name Yonas and 14:00.
    TEXT

    BOARD = "Board: Yonas rules folio GON-2026-1016-P5 at 14:00. When does Yonas rule?"

    Result = Struct.new(
      :brief,
      :thinking_tokens,
      :output_tokens,
      :thinking_cost,
      :total_cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_thinking(effort: :low, display: :summarized)
      chat.with_instructions(INSTRUCTIONS)
      brief = chat.ask(BOARD)
      Result.new(
        brief: brief.content,
        thinking_tokens: brief.tokens.thinking,
        output_tokens: brief.tokens.output,
        thinking_cost: brief.cost.thinking,
        total_cost: brief.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "parchment") do
    result = GondarParchmentFolio::ParchmentFolio.conduct
  end

  puts result.brief
  puts "thinking=#{result.thinking_tokens} output=#{result.output_tokens} cost_thinking=#{result.thinking_cost.inspect}"
end
