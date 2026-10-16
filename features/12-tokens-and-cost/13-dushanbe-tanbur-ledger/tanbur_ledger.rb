# frozen_string_literal: true

# Tokens and cost · 13 · Dushanbe tanbur ledger
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

module DushanbeTanburLedger
  Line = Struct.new(
    :label,
    :content,
    :input_tokens,
    :output_tokens,
    :thinking_tokens,
    :cost_total,
    keyword_init: true
  )

  # The overnight desk at the Dushanbe tanbur shop files a glue brief
  # and a follow-up about player Parvina, prints a ledger, then prices
  # that work on gpt-4.1-mini and gpt-4o-mini.
  class TanburLedger
    INSTRUCTIONS = <<~TEXT.strip
      You are the overnight glue clerk at the tanbur shop in Dushanbe.
      Keep each reply to two short sentences.
      Use only the boards in this chat.
      Name 3.4 kg and Parvina.
      Do not invent a dry time.
    TEXT

    GLUE_QUESTION = <<~TEXT.strip
      Dushanbe tanbur overnight board, Friday 16 October 2026.
      Shop notes: https://www.dushanbe.tj/
      Craft board: https://www.culture.tj/
      Hide glue 3.4 kg at the neck joint at 01:10.
      Clamp release 04:25.
      Player Parvina is holding the morning rehearsal until the clamp comes off.
      When is clamp release, and what is the glue weight?
    TEXT

    PLAYER_QUESTION = "Parvina wants to start the rehearsal at 03:50. May she go, or does she wait for 04:25?"

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
      opening = chat.ask(GLUE_QUESTION)
      follow_up = chat.ask(PLAYER_QUESTION)

      lines = [
        line_for("glue board", opening),
        line_for("player hail", follow_up)
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
  Multivitamin::Cassettes.play(__dir__, "tanbur_ledger") do
    result = DushanbeTanburLedger::TanburLedger.conduct
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
