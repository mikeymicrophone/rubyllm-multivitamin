# frozen_string_literal: true

# Durable agents and Rails · 10 · Wellington cable car batch
#
# Teaches:
# - Schedule a bounded batch by persisted IDs; reapply provider context on every find.
# - Ruby idiom: Lazy enumeration, zip/sum, filter_map, and an isolated context.

require_relative "../../../support/durable"

module WellingtonCableCarBatch
  class WatchLog < ActiveRecord::Base
    self.table_name = "wellington_cable_car_batch_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "WellingtonCableCarBatch::WatchEntry",
                 messages_foreign_key: :wellington_cable_car_batch_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "wellington_cable_car_batch_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "WellingtonCableCarBatch::WatchLog",
                    chat_foreign_key: :wellington_cable_car_batch_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class CableKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::CHAT, provider: :openrouter, assume_model_exists: true
    context -> { RubyLLM.context { |config| Multivitamin::Runtime.apply(config, provider: :openrouter) } }
    provider_options reasoning: { enabled: false }
    instructions "You keep Wellington's cable car maintenance cards. Repeat the named stop, crew and opening time in one sentence."
  end

  class CableJob < Multivitamin::DurableJob
    def perform(watch_id)
      watch = CableKeeper.find(watch_id)
      watch.step
      self.class.perform_later(watch_id) unless watch.complete? || watch.waiting?
    end
  end

  def self.conduct
    prepare!(provider: :openrouter, model: Multivitamin::Models::CHAT)
    stops = ["Kelburn", "Lambton"]
    crews = ["Moana at 08:50", "Wiremu at 09:05"]
    ids = stops.zip(crews).lazy.map do |stop, crew|
      CableKeeper.create!.tap { _1.ask_later("Wellington card: #{stop} opens for #{crew}.") }.id
    end.take(2).to_a
    ids.each { CableJob.perform_later(_1) }
    jobs = Multivitamin::Durable.drain
    completed = ids.filter_map do |watch_id|
      watch = CableKeeper.find(watch_id)
      watch.watch_entries.last.content if watch.complete?
    end
    { jobs: jobs, briefs: completed, assistant_count: ids.sum { WatchLog.find(_1).watch_entries.where(role: :assistant).count },
      provider: CableKeeper.find(ids.first).provider }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "cable_car_batch") do
    puts WellingtonCableCarBatch.conduct.inspect
  end
end
