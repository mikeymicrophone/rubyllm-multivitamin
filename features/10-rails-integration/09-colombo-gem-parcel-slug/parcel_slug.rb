# frozen_string_literal: true

# Rails integration · 09 · Colombo gem-parcel slug
#
# Teaches:
# - assume_model_exists on Chat.create! saves a ruby_llm_models row for
#   a slug that is newer than the bundled registry.
# - chat.model is RubyLLM::ActiveRecord::Model. There is no application
#   acts_as_model macro.
# - with_model switches the persisted association before the ask.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module ColomboGemParcelSlug
  class ParcelLog < ActiveRecord::Base
    self.table_name = "colombo_parcel_logs"
    acts_as_chat messages: :parcel_entries,
                 message_class: "ColomboGemParcelSlug::ParcelEntry",
                 messages_foreign_key: :colombo_parcel_log_id
  end

  class ParcelEntry < ActiveRecord::Base
    self.table_name = "colombo_parcel_entries"
    acts_as_message chat: :parcel_log,
                    chat_class: "ColomboGemParcelSlug::ParcelLog",
                    chat_foreign_key: :colombo_parcel_log_id
  end

  class ParcelClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the gem clerk at a cutting loft on Sea Street, Colombo.
      Answer in one short sentence from the parcel card only.
      Name the 9-stone sapphire parcel and the stone Lanka Star.
    TEXT

    PARCEL_QUESTION = <<~TEXT.strip
      Parcel card at the Sea Street loft, Wednesday 14 October 2026.
      Authority page: https://www.ngja.gov.lk/
      The blue sapphire Lanka Star sits in a 9-stone parcel on the velvet tray.
      Is that parcel ready for the cutter?
    TEXT

    Result = Struct.new(
      :brief,
      :assumed_model_id,
      :assumed_provider,
      :assumed_class,
      :asked_model_id,
      :registry_had_slug,
      :has_macro,
      :roles,
      keyword_init: true
    )

    def self.conduct
      boot
      assumed = {
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      }
      log = ParcelLog.create!(**assumed)
      registry_had_slug = begin
        RubyLLM.models.find(Multivitamin::Models::CHAT, provider: :openrouter)
        true
      rescue RubyLLM::ModelNotFoundError
        false
      end

      assumed_model_id = log.model_id
      assumed_provider = log.provider
      assumed_class = log.model.class.name

      paid = Multivitamin::Models.chat(provider: :openai)
      log.with_model(paid[:model], provider: paid[:provider], assume_model_exists: !paid[:assume_model_exists].nil?)
      log.with_instructions(INSTRUCTIONS)
      log.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(log, provider: :openai)
      brief = log.ask(PARCEL_QUESTION)

      Result.new(
        brief: brief.content,
        assumed_model_id: assumed_model_id,
        assumed_provider: assumed_provider,
        assumed_class: assumed_class,
        asked_model_id: log.model_id,
        registry_had_slug: registry_had_slug,
        has_macro: ActiveRecord::Base.respond_to?(:acts_as_model),
        roles: log.parcel_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :colombo_parcel_logs,
        message_table: :colombo_parcel_entries,
        message_foreign_key: :colombo_parcel_log_id
      )
      configure
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
  Multivitamin::Cassettes.play(__dir__, "parcel_slug") do
    result = ColomboGemParcelSlug::ParcelClerk.conduct
  end

  puts result.brief
end
