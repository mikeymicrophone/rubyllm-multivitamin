# frozen_string_literal: true

# Instructions and history · 01 · Point Wilson kelp-ledge standing orders
#
# Teaches:
# - with_instructions sets the system prompt.
# - The first chat.messages entry is :system.
# - On OpenAI Responses the clerk's orders ride in instructions, not input.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointWilsonClerkOrders
  # The evening tide clerk at Point Wilson posts standing orders, then
  # asks when the foghorn tender Alden must be back on the float.
  class ClerkOrders
    INSTRUCTIONS = <<~TEXT.strip
      You are the evening tide clerk at Point Wilson Light Station on Admiralty Inlet.
      These are the kelp-ledge standing orders.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the evening board in the question.
      Name Alden.
      Do not invent tide heights.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Evening board posted for Wednesday 14 October 2026 at Point Wilson.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      High water 12:18, 8.1 ft above MLLW.
      Low water 18:55, 2.6 ft.
      The foghorn tender Alden must be on the float before the falling tide
      drops through 4.5 ft, or she fouls the kelp ledge.
      Must Alden be back on the float before the 18:55 low, and is 4.5 ft
      still above that 2.6 ft low?
    TEXT

    Result = Struct.new(
      :brief,
      :roles,
      :first_role,
      :first_content,
      :finish,
      :input_tokens,
      :cost,
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
        roles: chat.messages.map(&:role),
        first_role: chat.messages.first.role,
        first_content: chat.messages.first.content,
        finish: brief.finish_reason,
        input_tokens: brief.tokens.input,
        cost: brief.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "clerk_orders") do
    result = PointWilsonClerkOrders::ClerkOrders.conduct
  end

  puts result.brief
end
