# frozen_string_literal: true

# Configuration and contexts · 03 · Cannery tenant and light station
#
# Teaches:
# - RubyLLM.context dups the global Configuration and yields the copy.
# - ctx.chat uses the copy. Two tenants can set different app names.
# - RubyLLM.config is left as it was after both chats.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module CanneryAndStationTenants
  # The Anacortes cannery and Point Wilson Light Station each get an
  # isolated context. The global attribution stays the catalog's.
  class Tenants
    GLOBAL_TITLE = "RubyLLM Multivitamin"
    STATION_TITLE = "Point Wilson Light Station"
    CANNERY_TITLE = "Anacortes Cannery retort desk"
    STATION_URL = "https://www.nps.gov/places/point-wilson-lighthouse.htm"
    CANNERY_URL = "https://www.portofanacortes.com/"

    STATION_INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Answer in one short sentence.
      Use only the tide board in the question.
      Name Alden and 10:46.
      Do not invent a tide height.
    TEXT

    STATION_QUESTION = <<~TEXT.strip
      Tide board posted for Wednesday 14 October 2026 at Point Wilson.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Alden clears the kelp ledge at 10:46.
      When can Alden leave the float this morning?
    TEXT

    CANNERY_INSTRUCTIONS = <<~TEXT.strip
      You are the retort clerk at the Anacortes cannery.
      Answer in one short sentence.
      Use only the cook card in the question.
      Name retort 2 and 242 F.
      Do not invent a basket.
    TEXT

    CANNERY_QUESTION = <<~TEXT.strip
      Morning cook card for Wednesday 14 October 2026, retort No. 2.
      Marina: https://www.portofanacortes.com/.
      Posted temperature 242 F.
      Basket 3 of sockeye.
      Write the log line for the cannery office.
    TEXT

    Result = Struct.new(
      :station_brief,
      :cannery_log,
      :station_title,
      :cannery_title,
      :global_title_after,
      :global_url_after,
      keyword_init: true
    )

    def self.conduct
      configure
      args = ConfigurationPaidOpenrouter.chat_args

      station = RubyLLM.context do |config|
        config.openrouter_app_name = STATION_TITLE
        config.openrouter_app_url = STATION_URL
      end
      station_chat = open_chat(station, args)
      station_chat.with_instructions(STATION_INSTRUCTIONS)
      station_chat.with_temperature(0.2)
      station_brief = station_chat.ask(STATION_QUESTION)

      cannery = RubyLLM.context do |config|
        config.openrouter_app_name = CANNERY_TITLE
        config.openrouter_app_url = CANNERY_URL
      end
      cannery_chat = open_chat(cannery, args)
      cannery_chat.with_instructions(CANNERY_INSTRUCTIONS)
      cannery_chat.with_temperature(0.2)
      cannery_log = cannery_chat.ask(CANNERY_QUESTION)

      Result.new(
        station_brief: station_brief.content,
        cannery_log: cannery_log.content,
        station_title: station.config.openrouter_app_name,
        cannery_title: cannery.config.openrouter_app_name,
        global_title_after: RubyLLM.config.openrouter_app_name,
        global_url_after: RubyLLM.config.openrouter_app_url
      )
    end

    def self.open_chat(context, args)
      ConfigurationPaidOpenrouter.prepare(context.chat(**args))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "tenants") do
    result = CanneryAndStationTenants::Tenants.conduct
  end

  puts "station (#{result.station_title}):"
  puts result.station_brief
  puts
  puts "cannery (#{result.cannery_title}):"
  puts result.cannery_log
end
