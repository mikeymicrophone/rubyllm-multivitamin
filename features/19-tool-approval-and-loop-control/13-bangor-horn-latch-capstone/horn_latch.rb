# frozen_string_literal: true

# Tool approval and loop control · 13 · Bangor horn latch capstone
#
# Teaches:
# - An unprotected range card runs while the horn waits on approval.
# - pending_approvals lists only the protected call. ask while waiting
#   raises PendingToolCallsError.
# - approve then complete sounds the horn. execute receives the ToolCall.
# - A follow-up ask on the finished chat sends both tool results back.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BangorHornLatchCapstone
  class PostedRangeCard < RubyLLM::Tool
    description "Reads the Bangor outbound range card. Does not sound the horn."

    def self.tool_name
      "posted_range_card"
    end

    CARD = <<~TEXT.strip
      Bangor range card, Thursday 15 October 2026.
      Range is clear. Submarine traffic: USS Kentucky outbound at 07:40.
    TEXT

    def self.reset!
      @read = false
    end

    def self.read?
      @read == true
    end

    def execute
      self.class.instance_variable_set(:@read, true)
      CARD
    end
  end

  class SoundTheHorn < RubyLLM::Tool
    description "Sounds the Hood Canal horn for outbound Bangor traffic. Needs the duty officer's latch."

    def self.tool_name
      "sound_the_horn"
    end

    requires_approval

    def self.reset!
      @sounded = false
      @call_id = nil
    end

    def self.sounded?
      @sounded == true
    end

    def self.call_id
      @call_id
    end

    def execute(tool_call: nil)
      self.class.instance_variable_set(:@sounded, true)
      self.class.instance_variable_set(:@call_id, tool_call&.id)
      "Hood Canal horn sounded. Blast 4 seconds for the Kentucky."
    end
  end

  class RestrictedGateLog < RubyLLM::Tool
    description "Reads the Bangor restricted-area gate log. Do not call this on the morning watch."

    def self.tool_name
      "restricted_gate_log"
    end

    def execute
      "Restricted-area gate log: closed. Do not open it on this watch."
    end
  end

  class DutyOfficer
    INSTRUCTIONS = <<~TEXT.strip
      You are the duty officer at Naval Base Kitsap-Bangor on Hood Canal.
      For the first question, your first message must contain exactly two
      function calls: posted_range_card and sound_the_horn. Do not call
      restricted_gate_log. After both have results, answer in one short
      sentence that names the Kentucky, the outbound clock on the range
      card, and the blast length the horn returns.
    TEXT

    TRAFFIC_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, morning watch at Bangor.
      Base notes: https://www.cnic.navy.mil/regions/cnrnw/installations/navbase_kitsap.html
      Chart: https://www.charts.noaa.gov/
      Read the outbound range and sound the horn for the Kentucky.
    TEXT

    FOLLOW_QUESTION = "The relief asks whether the Kentucky still leaves at the time on the range card, and whether the horn already sounded."

    Result = Struct.new(
      :card_read_while_waiting,
      :horn_sounded_while_waiting,
      :awaiting,
      :pending_names,
      :pending_error,
      :horn_sounded,
      :horn_call_id,
      :answer,
      :follow_up,
      :tool_contents,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      PostedRangeCard.reset!
      SoundTheHorn.reset!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(PostedRangeCard, SoundTheHorn, RestrictedGateLog)
      chat.with_tool_options(choice: :required, calls: :many)

      chat.ask(TRAFFIC_QUESTION)
      card_read_while_waiting = PostedRangeCard.read?
      horn_sounded_while_waiting = SoundTheHorn.sounded?
      awaiting = chat.awaiting_approval?
      pending_names = chat.pending_approvals.map(&:name)

      pending_error = nil
      begin
        chat.ask(FOLLOW_QUESTION)
      rescue RubyLLM::PendingToolCallsError => error
        pending_error = error.message
      end

      chat.pending_approvals.each { |tool_call| chat.approve(tool_call) }
      answer = chat.complete

      chat.with_tool_options(choice: :none)
      follow = chat.ask(FOLLOW_QUESTION)

      Result.new(
        card_read_while_waiting: card_read_while_waiting,
        horn_sounded_while_waiting: horn_sounded_while_waiting,
        awaiting: awaiting,
        pending_names: pending_names,
        pending_error: pending_error,
        horn_sounded: SoundTheHorn.sounded?,
        horn_call_id: SoundTheHorn.call_id,
        answer: answer&.content,
        follow_up: follow.content,
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
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
  Multivitamin::Cassettes.play(__dir__, "horn_latch") do
    result = BangorHornLatchCapstone::DutyOfficer.conduct
  end

  puts result.answer
  puts
  puts result.follow_up
end
