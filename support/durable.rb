# frozen_string_literal: true

require "active_job"
require_relative "runtime"
require_relative "active_record"

module Multivitamin
  # The test adapter serializes jobs, then the harness executes each payload
  # through ActiveJob's normal deserializer. No worker daemon is needed.
  class DurableJob < ActiveJob::Base
    self.queue_adapter = :test
    self.logger = Logger.new(File::NULL)
  end

  module Durable
    module_function

    def prepare!(chat_class:, message_class:, provider: :openai, model: Models::OPENAI_CHAT)
      Runtime.configure(provider: provider)
      ActiveRecordBoot.prepare!(
        chat_table: chat_class.table_name.to_sym,
        message_table: message_class.table_name.to_sym,
        message_foreign_key: :"#{chat_class.table_name.singularize}_id"
      )
      ActiveRecordBoot.seed_model(model_id: model, provider: provider)
      DurableJob.queue_adapter.enqueued_jobs.clear
      DurableJob.queue_adapter.performed_jobs.clear
    end

    def drain(limit: 20)
      adapter = DurableJob.queue_adapter
      performed = 0
      while (payload = adapter.enqueued_jobs.shift)
        raise "Durable job budget exceeded (#{limit})" if performed >= limit

        ActiveJob::Base.execute(payload)
        performed += 1
      end
      performed
    end

    def queued = DurableJob.queue_adapter.enqueued_jobs.size
  end
end
