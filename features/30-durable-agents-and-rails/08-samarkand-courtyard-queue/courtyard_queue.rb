# frozen_string_literal: true

# Durable agents and Rails · 08 · Samarkand courtyard queue
#
# Teaches:
# - A mixed tool batch does available work before waiting? stops re-enqueueing.
# - Ruby idiom: Class and instance tools together, each_with_object, and callbacks.

require_relative "../../../support/durable"

module SamarkandCourtyardQueue
  class WatchLog < ActiveRecord::Base
    self.table_name = "samarkand_courtyard_queue_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "SamarkandCourtyardQueue::WatchEntry",
                 messages_foreign_key: :samarkand_courtyard_queue_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "samarkand_courtyard_queue_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "SamarkandCourtyardQueue::WatchLog",
                    chat_foreign_key: :samarkand_courtyard_queue_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class ReadRoster < RubyLLM::Tool
    description "Read the Registan courtyard conservation roster"
    def self.tool_name = "read_roster"
    def execute = "Aziza leads 6 conservators at 09:30."
  end

  class OpenCourtyard < RubyLLM::Tool
    description "Open the Registan courtyard for the conservation crew"
    requires_approval
    def self.tool_name = "open_courtyard"
    def execute = "Registan courtyard opened for Aziza."
  end

  class CourtyardKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools { [ReadRoster, OpenCourtyard.new] }
    instructions "You keep Samarkand's Registan courtyard. Call read_roster and open_courtyard together. After approval report Aziza's entry."
  end

  class CourtyardJob < Multivitamin::DurableJob
    def perform(watch_id)
      watch = CourtyardKeeper.find(watch_id)
      watch.after_tool_result { |result| RubyLLM.logger.info("Registan roster posted: #{result}") }
      watch.step
      self.class.perform_later(watch_id) unless watch.complete? || watch.waiting?
    end
  end

  def self.conduct
    prepare!
    watch = CourtyardKeeper.create!
    watch.ask_later("Registan morning board: read the roster and request opening for Aziza's crew.")
    CourtyardJob.perform_later(watch.id)
    jobs = Multivitamin::Durable.drain
    found = CourtyardKeeper.find(watch.id)
    roles = found.watch_entries.each_with_object(Hash.new(0)) { |entry, counts| counts[entry.role] += 1 }
    { jobs: jobs, queued: Multivitamin::Durable.queued, waiting: found.waiting?, complete: found.complete?,
      pending: found.pending_approvals.map(&:name), role_counts: roles,
      roster: found.watch_entries.find_by(role: :tool).content }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "courtyard_queue") do
    puts SamarkandCourtyardQueue.conduct.inspect
  end
end
