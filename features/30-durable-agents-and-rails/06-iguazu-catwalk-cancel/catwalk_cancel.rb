# frozen_string_literal: true

# Durable agents and Rails · 06 · Iguazú catwalk cancel
#
# Teaches:
# - Persisted cancellation reaches a streaming worker; cleanup removes the unfinished assistant.
# - Ruby idiom: Chunk callback closure and a separate controller record.

require_relative "../../../support/durable"

module IguazuCatwalkCancel
  class WatchLog < ActiveRecord::Base
    self.table_name = "iguazu_catwalk_cancel_watch_logs"
    acts_as_chat messages: :watch_entries,
                 message_class: "IguazuCatwalkCancel::WatchEntry",
                 messages_foreign_key: :iguazu_catwalk_cancel_watch_log_id
  end

  class WatchEntry < ActiveRecord::Base
    self.table_name = "iguazu_catwalk_cancel_watch_entries"
    acts_as_message chat: :watch_log,
                    chat_class: "IguazuCatwalkCancel::WatchLog",
                    chat_foreign_key: :iguazu_catwalk_cancel_watch_log_id
  end

  def self.prepare!(**options)
    Multivitamin::Durable.prepare!(chat_class: WatchLog, message_class: WatchEntry, **options)
  end

  class FallsKeeper < RubyLLM::Agent
    chat_model WatchLog
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai, protocol: :chat_completions
    instructions "You keep the Iguazú catwalk watch. Read the four posted closures in order."
  end

  class StreamJob < Multivitamin::DurableJob
    def perform(watch_id)
      worker = FallsKeeper.find(watch_id)
      @spoken = []
      worker.complete do |chunk|
        next if chunk.content.to_s.empty?
        @spoken << chunk.content
        next unless @spoken.size == 1

        WatchLog.find(watch_id).cancel
        # The AR cancellation poll is throttled to one second. Let the
        # next stream checkpoint observe the other record's write.
        sleep 1.05
      end
    rescue RubyLLM::CancelledError
      @interrupted = true
    end

    attr_reader :spoken, :interrupted
  end

  def self.conduct
    prepare!
    watch = FallsKeeper.create!
    watch.ask_later("Iguazú card: Garganta footbridge closed; San Martín landing closed; upper loop open; ranger desk at 08:15.")
    job = StreamJob.new(watch.id)
    job.perform_now
    { spoken: job.spoken, interrupted: job.interrupted,
      roles: WatchLog.find(watch.id).watch_entries.map { _1.role.to_sym },
      assistants: WatchLog.find(watch.id).watch_entries.where(role: :assistant).count }
  end
end

if $PROGRAM_NAME == __FILE__
  Multivitamin::Cassettes.play(__dir__, "catwalk_cancel") do
    puts IguazuCatwalkCancel.conduct.inspect
  end
end
