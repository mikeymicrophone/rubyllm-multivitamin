# frozen_string_literal: true

# Rails integration · 06 · Harare mbira-key clerk
#
# Teaches:
# - with_instructions persists a system row on the workshop log.
# - append: true adds a second system row instead of replacing the first.
# - messages.where(role: :system) reads those rows back after a reload.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module HarareMbiraClerk
  class KeyLog < ActiveRecord::Base
    self.table_name = "harare_key_logs"
    acts_as_chat messages: :key_entries,
                 message_class: "HarareMbiraClerk::KeyEntry",
                 messages_foreign_key: :harare_key_log_id
  end

  class KeyEntry < ActiveRecord::Base
    self.table_name = "harare_key_entries"
    acts_as_message chat: :key_log,
                    chat_class: "HarareMbiraClerk::KeyLog",
                    chat_foreign_key: :harare_key_log_id
  end

  class KeyClerk
    WORKSHOP_RULE = <<~TEXT.strip
      You are the mbira clerk at a Mbare workshop in Harare.
      Answer in one short sentence from the key card only.
      Name the 22-key njari and the word tight.
    TEXT

    WAX_RULE = <<~TEXT.strip
      Add the beeswax: 18 grams at the bridge.
      Keep the key count.
    TEXT

    KEY_QUESTION = <<~TEXT.strip
      Key card at the Mbare workshop, Wednesday 14 October 2026 at 14:00.
      Gallery page: https://www.nationalgallery.co.zw/
      The 22-key njari is tight on the soundboard.
      What does the incoming tuner need from the card?
    TEXT

    Result = Struct.new(
      :brief,
      :system_count,
      :system_texts,
      :reloaded_system_count,
      :roles,
      keyword_init: true
    )

    def self.conduct
      log = open_log
      log.with_instructions(WORKSHOP_RULE)
      log.with_instructions(WAX_RULE, append: true)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(KEY_QUESTION)

      systems = log.key_entries.where(role: :system)
      reloaded = KeyLog.find(log.id)
      Result.new(
        brief: brief.content,
        system_count: systems.count,
        system_texts: systems.order(:id).map(&:content),
        reloaded_system_count: reloaded.key_entries.where(role: :system).count,
        roles: log.key_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.open_log
      choice = boot
      KeyLog.create!(**choice)
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :harare_key_logs,
        message_table: :harare_key_entries,
        message_foreign_key: :harare_key_log_id
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
  Multivitamin::Cassettes.play(__dir__, "key_clerk") do
    result = HarareMbiraClerk::KeyClerk.conduct
  end

  puts result.brief
end
