# frozen_string_literal: true

# Durable agents and Rails · 01 · Kyoto torii watch
#
# Teaches:
# - One persisted move per ActiveJob; enqueue unless complete? or waiting?.
# - Ruby idiom: Instance-owned scheduler and endless methods.

require_relative "../../../support/durable"

module KyotoToriiWatch
  class WatchLog < ActiveRecord::Base
    self.table_name = "kyoto_torii_watch_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "KyotoToriiWatch::WatchEntry",
                 messages_foreign_key: :kyoto_torii_watch_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "kyoto_torii_watch_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "KyotoToriiWatch::WatchLog",
                    chat_foreign_key: :kyoto_torii_watch_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class PathWidth < RubyLLM::Tool
    description "Read the posted width at Fushimi Inari's lower torii passage"
    def self.tool_name = "path_width"
    def execute = "Lower passage: 2.4 m clear; lantern crew enters at 06:20."
  end

  class GateKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools PathWidth
    instructions "You keep the Fushimi Inari watch in Kyoto. Call path_width, then state the width and lantern crew time in one sentence."
  end

  class WatchJob < Multivitamin::DurableJob
    def perform(watch_id)
      watch = GateKeeper.find(watch_id)
      watch.step
      self.class.perform_later(watch_id) unless watch.complete? || watch.waiting?
    end
  end

  class MorningWatch
    def initialize
      @watch = GateKeeper.create!
    end

    def dispatch
      @watch.ask_later("Lantern crew card: check the lower torii passage before the 06:20 entry.")
      WatchJob.perform_later(@watch.id)
      jobs = Multivitamin::Durable.drain
      found = GateKeeper.find(@watch.id)
      { jobs: jobs, complete: found.complete?, brief: found.watch_entries.last.content,
        roles: found.watch_entries.map { _1.role.to_sym }, usages: RubyLLM::ActiveRecord::Usage.count }
    end
  end

  def self.conduct
    prepare!
    MorningWatch.new.dispatch
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "torii_watch") do
    puts KyotoToriiWatch.conduct.inspect
  end
end
