# frozen_string_literal: true

# Batches · 04 · Tamale calabash-bowl tool then rebatch
#
# Teaches:
# - A chat must be awaiting the model before it can enter a batch.
# - After a live tool round, ask_later stages the next turn for RubyLLM.batch.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TamaleCalabashBowl
  class PostedCalabashCard < RubyLLM::Tool
    description "Reads the calabash bowl card posted at the Tamale yard"

    def self.tool_name
      "posted_calabash_card"
    end

    CARD = <<~TEXT.strip
      Tamale calabash yard card for Friday 16 October 2026.
      Bench TM-4, 9 bowls, cart Kojo alongside at 06:50.
    TEXT

    def execute
      CARD
    end
  end

  class BowlBatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the bowl clerk at the calabash yard in Tamale.
      Call posted_calabash_card once when you need the card.
      Then answer in two short sentences. Name 9 bowls and Kojo.
    TEXT

    FIRST = <<~TEXT.strip
      Morning calabash at the Tamale yard. How many bowls, and which cart is alongside?
    TEXT

    FOLLOW = <<~TEXT.strip
      Confirm the bench id from the same card.
    TEXT

    Result = Struct.new(:tool_roles, :batch_id, :status, :awaiting, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_tools(PostedCalabashCard)
      chat.with_tool_options(choice: PostedCalabashCard)
      chat.ask(FIRST)
      tool_roles = chat.messages.map(&:role)
      chat.ask_later(FOLLOW)
      awaiting = !chat.complete? && %i[user tool].include?(chat.messages.last.role)
      batch = RubyLLM.batch([chat])
      Result.new(tool_roles: tool_roles, batch_id: batch.id, status: batch.status, awaiting: awaiting)
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

    def self.open_chat(model: nil)
      kwargs = Multivitamin::Models.chat(provider: :openai)
      kwargs = kwargs.merge(model: model) if model
      chat = RubyLLM.chat(**kwargs)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "calabash_bowl") do
    result = TamaleCalabashBowl::BowlBatch.conduct
  end
  puts "roles=#{result.tool_roles.join(",")} id=#{result.batch_id} awaiting=#{result.awaiting}"
end
