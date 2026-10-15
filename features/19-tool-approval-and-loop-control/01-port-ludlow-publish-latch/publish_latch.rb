# frozen_string_literal: true

# Tool approval and loop control · 01 · Port Ludlow publish latch
#
# Teaches:
# - requires_approval parks ask. execute has not run.
# - awaiting_approval? and pending_approvals name the waiting call.
# - approve then complete runs the tool and lets the model speak.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortLudlowPublishLatch
  class PublishWatchNotice < RubyLLM::Tool
    description "Publishes the evening watch notice on the Port Ludlow marina board. Needs the dockmaster's latch."

    def self.tool_name
      "publish_watch_notice"
    end

    requires_approval

    NOTICE = <<~TEXT.strip
      Port Ludlow evening notice, Thursday 15 October 2026.
      Fog expected after 21:00. The tender Marrowstone holds at the inner float.
    TEXT

    def self.reset!
      @posted = false
    end

    def self.posted?
      @posted == true
    end

    def execute
      self.class.instance_variable_set(:@posted, true)
      NOTICE
    end
  end

  class Dockmaster
    INSTRUCTIONS = <<~TEXT.strip
      You are the dockmaster at Port Ludlow Marina on Hood Canal.
      Call publish_watch_notice once.
      After it runs, answer in one short sentence that names Marrowstone
      and the fog clock the notice gives. Do not invent a holding.
    TEXT

    NOTICE_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, evening watch at Port Ludlow Marina.
      Marina notes: https://www.portludlowmarina.com/
      Post the fog notice for the tender Marrowstone.
    TEXT

    Result = Struct.new(
      :parked_role,
      :awaiting,
      :waiting,
      :pending_name,
      :posted_before_approve,
      :posted_after,
      :answer,
      :tool_content,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      PublishWatchNotice.reset!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(PublishWatchNotice)
      chat.with_tool_options(choice: PublishWatchNotice)

      parked = chat.ask(NOTICE_QUESTION)
      pending = chat.pending_approvals.first
      posted_before_approve = PublishWatchNotice.posted?
      awaiting = chat.awaiting_approval?
      waiting = chat.waiting?
      parked_role = parked&.role
      pending_name = pending&.name

      chat.approve(pending) if pending
      answer = chat.complete
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        parked_role: parked_role,
        awaiting: awaiting,
        waiting: waiting,
        pending_name: pending_name,
        posted_before_approve: posted_before_approve,
        posted_after: PublishWatchNotice.posted?,
        answer: answer&.content,
        tool_content: tool_message&.content,
        roles: chat.messages.map(&:role)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "publish_latch") do
    result = PortLudlowPublishLatch::Dockmaster.conduct
  end

  puts result.answer
end
