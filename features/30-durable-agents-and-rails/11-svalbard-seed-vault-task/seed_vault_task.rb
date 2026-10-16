# frozen_string_literal: true

# Durable agents and Rails · 11 · Svalbard seed vault task
#
# Teaches:
# - Persist an MCP task on the tool call; a fresh Agent.find checks once per scheduled job.
# - Ruby idiom: MCP task snapshots, ensure cleanup, and delayed polling jobs.

require_relative "../../../support/durable"

module SvalbardSeedVaultTask
  class WatchLog < ActiveRecord::Base
    self.table_name = "svalbard_seed_vault_task_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "SvalbardSeedVaultTask::WatchEntry",
                 messages_foreign_key: :svalbard_seed_vault_task_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "svalbard_seed_vault_task_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "SvalbardSeedVaultTask::WatchLog",
                    chat_foreign_key: :svalbard_seed_vault_task_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class VaultDesk < RubyLLM::MCP
    # Reserved .invalid address: VCR supplies the hand-authored server.
    # Set VAULT_MCP_URL to a compatible real server when re-recording.
    url ENV.fetch("VAULT_MCP_URL", "https://svalbard-vault.invalid/mcp")
    extension :tasks
  end

  class SeedKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    mcp VaultDesk
    instructions "You keep the Svalbard seed vault intake. Call reconcile_crates once, then report the crate count when the task finishes."
  end

  class PollJob < Multivitamin::DurableJob
    def perform(watch_id)
      watch = SeedKeeper.find(watch_id)
      watch.complete
      self.class.set(wait: 5).perform_later(watch_id) if watch.awaiting_tasks?
    ensure
      watch&.mcp&.each(&:close)
    end
  end

  def self.conduct
    prepare!
    watch = SeedKeeper.create!
    watch.ask("Svalbard intake: reconcile the NordGen seed crates for shelf B-12.")
    saved_state = RubyLLM::ActiveRecord::ToolCall.first.mcp_state.deep_dup
    task_id = watch.pending_tasks.first.id
    watch.mcp.each(&:close)
    PollJob.perform_later(watch.id)
    jobs = Multivitamin::Durable.drain
    found = SeedKeeper.find(watch.id)
    { task_id: task_id, saved_state: saved_state, jobs: jobs, complete: found.complete?,
      brief: found.watch_entries.last.content, results: found.watch_entries.where(role: :tool).count }
  ensure
    found&.mcp&.each(&:close)
    watch&.mcp&.each(&:close)
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "seed_vault_task") do
    puts SvalbardSeedVaultTask.conduct.inspect
  end
end
