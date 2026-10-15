# frozen_string_literal: true

# Tool approval and loop control · 07 · Lilliwaup concurrency threads
#
# Teaches:
# - concurrency: :threads runs two I/O-bound tools on Ruby threads.
# - calls: :many lets one assistant turn carry both calls.
# - Tool results join the transcript as each call finishes.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LilliwaupConcurrencyThreads
  class CreekStage < RubyLLM::Tool
    description "Reads the county stage gauge on Lilliwaup Creek"

    def self.tool_name
      "creek_stage"
    end

    def execute
      Thread.current[:lilliwaup_tool] = "creek_stage"
      LilliwaupConcurrencyThreads.record_worker("creek_stage")
      # Shorter than BoomLog so the creek card is appended first on record
      # and on replay. Concurrent completion order is part of the request body.
      sleep 0.02
      "Lilliwaup Creek stage 3.8 ft at the county gauge."
    end
  end

  class BoomLog < RubyLLM::Tool
    description "Reads the hemlock stick count in the Lilliwaup boom pocket"

    def self.tool_name
      "boom_log"
    end

    def execute
      Thread.current[:lilliwaup_tool] = "boom_log"
      LilliwaupConcurrencyThreads.record_worker("boom_log")
      sleep 0.08
      "Lilliwaup boom pocket holds 42 sticks of hemlock."
    end
  end

  @workers = []
  @workers_mutex = Mutex.new

  def self.record_worker(name)
    @workers_mutex.synchronize do
      @workers << { name: name, thread_id: Thread.current.object_id }
    end
  end

  def self.reset_workers!
    @workers_mutex.synchronize { @workers = [] }
  end

  def self.workers
    @workers_mutex.synchronize { @workers.dup }
  end

  class CreekWatch
    INSTRUCTIONS = <<~TEXT.strip
      You are the mill watch at Lilliwaup.
      Your first message must contain exactly two function calls:
      creek_stage and boom_log. Do not wait for a result before the
      second call. Then answer in one short sentence that names the stage
      and the stick count the tools return.
    TEXT

    CREEK_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, mill round at Lilliwaup Creek.
      Canal notes: https://www.fs.usda.gov/olympic
      Read the county stage and the boom pocket together.
    TEXT

    Result = Struct.new(
      :answer,
      :tool_contents,
      :call_count,
      :worker_names,
      :thread_ids,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      LilliwaupConcurrencyThreads.reset_workers!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(CreekStage, BoomLog)
      chat.with_tool_options(choice: :required, calls: :many, concurrency: :threads)

      answer = chat.ask(CREEK_QUESTION)
      tool_turn = chat.messages.find(&:tool_call?)
      workers = LilliwaupConcurrencyThreads.workers

      Result.new(
        answer: answer.content,
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        call_count: tool_turn&.tool_calls&.size,
        worker_names: workers.map { |worker| worker[:name] }.sort,
        thread_ids: workers.map { |worker| worker[:thread_id] },
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
  Multivitamin::Cassettes.play(__dir__, "creek_and_boom") do
    result = LilliwaupConcurrencyThreads::CreekWatch.conduct
  end

  puts result.answer
end
