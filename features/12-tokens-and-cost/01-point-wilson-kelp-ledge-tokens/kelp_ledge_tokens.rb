# frozen_string_literal: true

# Tokens and cost · 01 · Point Wilson kelp-ledge token tally
#
# Teaches:
# - response.tokens is a RubyLLM::Tokens.
# - tokens.input and tokens.output are integers on a finished message.
# - cost.total is read off the same message.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonKelpLedgeTokens
  # The incoming watch at Point Wilson needs one kelp-ledge window off
  # the posted board. The clerk reads the token counts on that brief.
  class KelpLedgeTokens
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Answer in two short sentences.
      Use only the tide board in the question.
      Name Alden and 10:46.
      Do not invent a tide height.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Tide board posted for Wednesday 14 October 2026 at Point Wilson.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      The foghorn tender Alden needs 6.0 ft at the float to clear the kelp ledge.
      Alden clears that ledge at 10:46 on the rise.
      When can Alden leave the float this morning?
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
  Multivitamin::Cassettes.play(__dir__, "kelp_ledge_tokens") do
    result = PointWilsonKelpLedgeTokens::KelpLedgeTokens.conduct
  end

  puts result.brief
  puts "tokens in=#{result.input_tokens} out=#{result.output_tokens} thinking=#{result.thinking_tokens} " \
       "cost=#{result.cost_total.inspect}"
end
