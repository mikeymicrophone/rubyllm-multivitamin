# frozen_string_literal: true

# Durable agents and Rails · 03 · Cusco terrace checkpoint
#
# Teaches:
# - ActiveJob::Continuable checkpoints after each chat.step and resumes after interruption.
# - Ruby idiom: Continuation cursor, explicit loop, and serialized resumption.

require_relative "../../../support/durable"

module CuscoTerraceCheckpoint
  class WatchLog < ActiveRecord::Base
    self.table_name = "cusco_terrace_checkpoint_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "CuscoTerraceCheckpoint::WatchEntry",
                 messages_foreign_key: :cusco_terrace_checkpoint_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "cusco_terrace_checkpoint_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "CuscoTerraceCheckpoint::WatchLog",
                    chat_foreign_key: :cusco_terrace_checkpoint_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class ReadTerrace < RubyLLM::Tool
    description "Read Rosa's posted survey entry at the Qenqo terrace gate"
    def self.tool_name = "read_terrace"
    def execute = "Qenqo gate opens at 07:10 for Rosa's survey crew."
  end

  class TerraceKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools ReadTerrace
    instructions "You keep the Sacsayhuamán terrace watch near Cusco. Call read_terrace, then repeat the posted gate and time in one sentence."
  end

  class TerraceJob < Multivitamin::DurableJob
    include ActiveJob::Continuable
    self.max_resumptions = 2
    self.resume_options = { wait: 0 }

    def perform(watch_id)
      watch = TerraceKeeper.find(watch_id)
      step :terrace_turns, start: 0 do |checkpoint|
        until watch.complete? || watch.waiting?
          watch.step
          checkpoint.advance!
          # Exercise a deploy boundary after persisted progress, once.
          interrupt!(reason: :deploy) unless checkpoint.resumed?
        end
      end
      step :file_handover do
        watch.watch_entries.last.content
      end
    end
  end

  def self.conduct
    prepare!
    watch = TerraceKeeper.create!
    watch.ask_later("Cusco terrace card: Qenqo gate opens at 07:10 for Rosa's survey crew.")
    job = TerraceJob.new(watch.id)
    job.perform_now
    payload = Multivitamin::DurableJob.queue_adapter.enqueued_jobs.first
    cursor = payload.fetch("continuation").fetch("current")
    resumed_jobs = Multivitamin::Durable.drain
    found = TerraceKeeper.find(watch.id)
    { cursor: cursor, resumed_jobs: resumed_jobs, brief: found.watch_entries.last.content,
      assistants: found.watch_entries.where(role: :assistant).count,
      tool_results: found.watch_entries.where(role: :tool).count, complete: found.complete? }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "terrace_checkpoint") do
    puts CuscoTerraceCheckpoint.conduct.inspect
  end
end
