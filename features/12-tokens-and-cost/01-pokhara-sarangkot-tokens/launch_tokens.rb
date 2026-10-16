# frozen_string_literal: true

# Tokens and cost · 01 · Pokhara Sarangkot launch tokens
#
# Teaches:
# - response.tokens is a RubyLLM::Tokens.
# - tokens.input and tokens.output are integers on a finished message.
# - cost.total is read off the same message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PokharaSarangkotTokens
  # The launch clerk at Sarangkot reads one thermal window off the posted
  # board, then files the token counts on that brief.
  class LaunchTokens
    INSTRUCTIONS = <<~TEXT.strip
      You are the hang-glider launch clerk at Sarangkot, above Pokhara.
      Answer in two short sentences.
      Use only the launch board in the question.
      Name Nabin and 10:46.
      Do not invent a wind speed.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Launch board posted for Friday 16 October 2026 at Sarangkot, Pokhara.
      Ridge notes: https://www.welcomenepal.com/
      Dawn thermal 06:42, ridge 8 knots from the south.
      Mid-morning window 12:18, ridge 12 knots.
      Pilot Nabin needs 10 knots at the takeoff to clear the terrace wall.
      Nabin launches at 10:46 on the rising thermal.
      When can Nabin leave the takeoff this morning?
    TEXT

    Result = Struct.new(
      :brief,
      :input_tokens,
      :output_tokens,
      :thinking_tokens,
      :cost_total,
      :finish,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(BOARD_QUESTION)

      Result.new(
        brief: brief.content,
        input_tokens: brief.tokens.input,
        output_tokens: brief.tokens.output,
        thinking_tokens: brief.tokens.thinking,
        cost_total: brief.cost.total,
        finish: brief.finish_reason,
        roles: chat.messages.map(&:role)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "launch_tokens") do
    result = PokharaSarangkotTokens::LaunchTokens.conduct
  end

  puts result.brief
  puts "tokens in=#{result.input_tokens} out=#{result.output_tokens} thinking=#{result.thinking_tokens} " \
       "cost=#{result.cost_total.inspect}"
end
