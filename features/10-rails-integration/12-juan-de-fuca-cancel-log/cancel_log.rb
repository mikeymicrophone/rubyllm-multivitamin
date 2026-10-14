# frozen_string_literal: true

# Rails integration · 12 · Juan de Fuca cancel log
#
# Teaches:
# - cancel on a persisted chart log sets the cancelled column and raises
#   RubyLLM::CancelledError at the next chunk.
# - The blank assistant row created for the stream is destroyed.
# - CancelledError inherits StandardError, not RubyLLM::Error.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module JuanDeFucaCancelLog
  class ChartLog < ActiveRecord::Base
    self.table_name = "juan_de_fuca_chart_logs"
    acts_as_chat messages: :chart_entries,
                 message_class: "JuanDeFucaCancelLog::ChartEntry",
                 messages_foreign_key: :juan_de_fuca_chart_log_id
  end

  class ChartEntry < ActiveRecord::Base
    self.table_name = "juan_de_fuca_chart_entries"
    acts_as_message chat: :chart_log,
                    chat_class: "JuanDeFucaCancelLog::ChartLog",
                    chat_foreign_key: :juan_de_fuca_chart_log_id
  end

  class ChartClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the chart clerk for the Strait of Juan de Fuca.
      Call four corrections in order, one short sentence each.
      Use only the notice on the card.
    TEXT

    NOTICE_QUESTION = <<~TEXT.strip
      Chart notice Wednesday 14 October 2026, Strait of Juan de Fuca.
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      First correction: Race Rocks light is extinguished.
      Second correction: Hein Bank buoy is off station.
      Third correction: New Dungeness range is as charted.
      Fourth correction: Ediz Hook whistle is silent.
      Call the four corrections.
    TEXT

    Result = Struct.new(
      :spoken,
      :error_class,
      :error_parent,
      :cancelled_during,
      :roles,
      :assistant_count,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)

      spoken = []
      cancelled_during = false
      error = nil
      begin
        log.ask(NOTICE_QUESTION) do |chunk|
          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          if spoken.size == 2
            log.cancel
            cancelled_during = log.cancelled?
          end
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      Result.new(
        spoken: spoken,
        error_class: error&.class,
        error_parent: error&.class&.superclass,
        cancelled_during: cancelled_during,
        roles: log.chart_entries.map { |entry| entry.role.to_sym },
        assistant_count: log.chart_entries.where(role: :assistant).count
      )
    end

    def self.open_log
      choice = boot
      ChartLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :juan_de_fuca_chart_logs,
        message_table: :juan_de_fuca_chart_entries,
        message_foreign_key: :juan_de_fuca_chart_log_id
      )
      choice = Multivitamin::Models.chat(provider: :openai)
      Multivitamin::ActiveRecordBoot.seed_model(model_id: choice[:model], provider: choice[:provider])
      configure
      choice
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
  Multivitamin::Cassettes.play(__dir__, "cancel_log") do
    result = JuanDeFucaCancelLog::ChartClerk.conduct
  end

  puts result.spoken.join
  puts
  puts result.error_class
end
