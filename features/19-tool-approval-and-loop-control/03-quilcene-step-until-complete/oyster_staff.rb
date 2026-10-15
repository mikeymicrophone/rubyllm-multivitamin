# frozen_string_literal: true

# Tool approval and loop control · 03 · Quilcene step until complete?
#
# Teaches:
# - ask_later stages the oyster question without a provider call.
# - step does whichever move is next: generate, then run_tools, then
#   generate again.
# - Stop with `step until complete? || waiting?`. A second step is nil.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module QuilceneStepUntilComplete
  class PostedOysterStaff < RubyLLM::Tool
    description "Reads the oyster tide staff posted at Quilcene Bay"

    def self.tool_name
      "posted_oyster_staff"
    end

    STAFF = <<~TEXT.strip
      Quilcene oyster staff, Thursday 15 October 2026.
      Low water 07:22, 1.4 ft above MLLW. The beds at Linger Longer can be walked at 08:10.
    TEXT

    def execute
      STAFF
    end
  end

  class BedClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the oyster clerk at Quilcene Bay.
      Call posted_oyster_staff once.
      Answer in one short sentence that names Linger Longer and the walk
      clock the staff gives. Do not invent a height.
    TEXT

    STAFF_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, oyster watch at Quilcene Bay.
      Tide station: https://tidesandcurrents.noaa.gov/stationhome.html?id=9445016
      When can the crew walk the Linger Longer beds?
    TEXT

    Result = Struct.new(
      :complete_after_later,
      :move_roles,
      :second_step,
      :settled,
      :waiting,
      :answer,
      :tool_content,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(PostedOysterStaff)
      chat.with_tool_options(choice: PostedOysterStaff)

      chat.ask_later(STAFF_QUESTION)
      complete_after_later = chat.complete?

      move_roles = []
      chat.step until chat.complete? || chat.waiting?
      chat.messages.each do |message|
        next if message.role == :system || message.role == :user

        move_roles << message.role
      end
      extra = chat.step

      tool_message = chat.messages.find { |message| message.role == :tool }
      speech = chat.messages.reverse.find { |message| message.role == :assistant && !message.tool_call? }

      Result.new(
        complete_after_later: complete_after_later,
        move_roles: move_roles,
        second_step: extra,
        settled: chat.complete?,
        waiting: chat.waiting?,
        answer: speech&.content,
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
  Multivitamin::Cassettes.play(__dir__, "oyster_staff") do
    result = QuilceneStepUntilComplete::BedClerk.conduct
  end

  puts result.answer
end
