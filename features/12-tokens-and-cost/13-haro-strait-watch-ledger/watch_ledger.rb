# frozen_string_literal: true

# Tokens and cost · 13 · Haro Strait watch ledger
#
# Teaches:
# - A ledger prints tokens and cost for each turn and for the chat.
# - The same token work prices differently on two registry models.
# - A watch budget is a dollar cap compared to those estimates, not to
#   the free slug's reported zero.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HaroStraitWatchLedger
  Line = Struct.new(
    :label,
    :content,
    :input_tokens,
    :output_tokens,
    :thinking_tokens,
    :cost_total,
    keyword_init: true
  )

  # The overnight desk on Haro Strait files a Turn Point brief and a
  # follow-up about the tanker Polar Adventure, prints a ledger, then
  # prices that work on gpt-4.1-mini and gpt-4o-mini.
  class WatchLedger
    INSTRUCTIONS = <<~TEXT.strip
      You are the overnight current clerk at Turn Point Light, looking into Haro Strait.
      Keep each reply to two short sentences.
      Use only the boards in this chat.
      Name 3.4 knots and Polar Adventure.
      Do not invent a slack time.
    TEXT

    RACE_QUESTION = <<~TEXT.strip
      Haro Strait overnight board, Wednesday 14 October 2026.
      Light list: https://www.navcen.uscg.gov/
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      Flood 3.4 knots at Turn Point at 01:10.
      Slack before ebb 04:25.
      Tanker Polar Adventure is holding south of the light until slack.
      When is slack, and what is the flood?
    TEXT

    TANKER_QUESTION = "Polar Adventure wants to start north at 03:50. May she go, or does she wait for 04:25?"

    WATCH_BUDGET = 0.01

    Result = Struct.new(
      :lines,
      :chat_input,
      :chat_output,
      :chat_cost,
      :roles,
      :mini_total,
      :mini_input_price,
      :nano_total,
      :nano_input_price,
      :cheaper_id,
      :under_budget,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      opening = chat.ask(RACE_QUESTION)
      follow_up = chat.ask(TANKER_QUESTION)

      lines = [
        line_for("flood board", opening),
        line_for("tanker hail", follow_up)
      ]

      work = RubyLLM::Tokens.new(
        input: chat.tokens.input,
        output: chat.tokens.output
      )
      mini = RubyLLM.models.find("gpt-4.1-mini", provider: :openai)
      nano = RubyLLM.models.find("gpt-4o-mini", provider: :openai)
      mini_cost = mini.cost_for(work)
      nano_cost = nano.cost_for(work)
      cheaper = nano_cost.total < mini_cost.total ? nano.id : mini.id

      Result.new(
        lines: lines,
        chat_input: chat.tokens.input,
        chat_output: chat.tokens.output,
        chat_cost: chat.cost.total,
        roles: chat.messages.map(&:role),
        mini_total: mini_cost.total,
        mini_input_price: mini.price(:input),
        nano_total: nano_cost.total,
        nano_input_price: nano.price(:input),
        cheaper_id: cheaper,
        under_budget: mini_cost.total < WATCH_BUDGET
      )
    end

    def self.line_for(label, message)
      Line.new(
        label: label,
        content: message.content,
        input_tokens: message.tokens.input,
        output_tokens: message.tokens.output,
        thinking_tokens: message.tokens.thinking,
        cost_total: message.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "watch_ledger") do
    result = HaroStraitWatchLedger::WatchLedger.conduct
  end

  result.lines.each do |line|
    puts "#{line.label} in=#{line.input_tokens} out=#{line.output_tokens} cost=#{line.cost_total.inspect}"
    puts line.content
    puts
  end
  puts "chat in=#{result.chat_input} out=#{result.chat_output} cost=#{result.chat_cost.inspect}"
  puts "gpt-4.1-mini #{result.mini_total} gpt-4o-mini #{result.nano_total} cheaper=#{result.cheaper_id} " \
       "under_budget=#{result.under_budget}"
end
