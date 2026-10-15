# frozen_string_literal: true

# Rails integration · 09 · Neah Bay pilot slug
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

module NeahBayPilotSlug
  class PilotLog < ActiveRecord::Base
    self.table_name = "neah_bay_pilot_logs"
    acts_as_chat messages: :pilot_entries,
                 message_class: "NeahBayPilotSlug::PilotEntry",
                 messages_foreign_key: :neah_bay_pilot_log_id
  end

  class PilotEntry < ActiveRecord::Base
    self.table_name = "neah_bay_pilot_entries"
    acts_as_message chat: :pilot_log,
                    chat_class: "NeahBayPilotSlug::PilotLog",
                    chat_foreign_key: :neah_bay_pilot_log_id
  end

  class PilotClerk
    INSTRUCTIONS = <<~TEXT.strip
      You are the pilot clerk off Neah Bay.
      Answer in one short sentence from the ladder card only.
      Name the 9-rung boarding ladder and the tanker Kulshan.
    TEXT

    LADDER_QUESTION = <<~TEXT.strip
      Pilot boarding card off Neah Bay, Wednesday 14 October 2026.
      Coast Pilot: https://nauticalcharts.noaa.gov/publications/coast-pilot/index.html
      The tanker Kulshan streams a 9-rung ladder on the starboard side.
      Is that ladder ready for the pilot?
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
      log = PilotLog.create!(**assumed)
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
      brief = log.ask(LADDER_QUESTION)

      Result.new(
        brief: brief.content,
        assumed_model_id: assumed_model_id,
        assumed_provider: assumed_provider,
        assumed_class: assumed_class,
        asked_model_id: log.model_id,
        registry_had_slug: registry_had_slug,
        has_macro: ActiveRecord::Base.respond_to?(:acts_as_model),
        roles: log.pilot_entries.map { |entry| entry.role.to_sym }
      )
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :neah_bay_pilot_logs,
        message_table: :neah_bay_pilot_entries,
        message_foreign_key: :neah_bay_pilot_log_id
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
  Multivitamin::Cassettes.play(__dir__, "pilot_slug") do
    result = NeahBayPilotSlug::PilotClerk.conduct
  end

  puts result.brief
end
