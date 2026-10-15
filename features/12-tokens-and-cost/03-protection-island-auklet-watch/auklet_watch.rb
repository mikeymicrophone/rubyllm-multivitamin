# frozen_string_literal: true

# Tokens and cost · 03 · Protection Island auklet-watch totals
#
# Teaches:
# - chat.tokens sums every attempt on that chat.
# - With no retries, chat.tokens.input equals the sum of the two replies.
# - A second ask grows the input count because the first turn goes back.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ProtectionIslandAukletWatch
  # The refuge clerk on Protection Island logs the morning auklet count,
  # then answers a second hail about the closed landing. Both turns sit
  # on one chat, and the watch reads the summed tokens.
  class AukletWatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the refuge clerk on Protection Island, south of Discovery Bay.
      Keep each reply to two short sentences.
      Use only the count card in this chat.
      Name rhinoceros auklets and 1,240.
      Do not invent a landing time.
    TEXT

    COUNT_QUESTION = <<~TEXT.strip
      Morning auklet card, Protection Island National Wildlife Refuge, Wednesday 14 October 2026, 06:20.
      Refuge notes: https://www.fws.gov/refuge/protection-island
      Rhinoceros auklets on the burrow count: 1,240.
      The landing at Kanem Point is closed to the public until 09:00 for the count.
      The skiff Cassin's is standing off with the count crew.
      How many rhinoceros auklets, and is the landing closed?
    TEXT

    LANDING_QUESTION = "Cassin's wants to put two extra counters ashore at Kanem Point before 09:00. May they land?"

    Result = Struct.new(
      :count_brief,
      :landing_brief,
      :opening_input,
      :follow_up_input,
      :chat_input,
      :chat_output,
      :chat_cost,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      opening = chat.ask(COUNT_QUESTION)
      follow_up = chat.ask(LANDING_QUESTION)

      Result.new(
        count_brief: opening.content,
        landing_brief: follow_up.content,
        opening_input: opening.tokens.input,
        follow_up_input: follow_up.tokens.input,
        chat_input: chat.tokens.input,
        chat_output: chat.tokens.output,
        chat_cost: chat.cost.total,
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
  Multivitamin::Cassettes.play(__dir__, "auklet_watch") do
    result = ProtectionIslandAukletWatch::AukletWatch.conduct
  end

  puts result.count_brief
  puts
  puts result.landing_brief
  puts "chat in=#{result.chat_input} opening=#{result.opening_input} follow=#{result.follow_up_input}"
end
