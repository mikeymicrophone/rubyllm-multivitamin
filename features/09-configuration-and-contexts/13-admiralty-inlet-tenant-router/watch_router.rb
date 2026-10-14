# frozen_string_literal: true

# Configuration and contexts · 13 · Admiralty Inlet tenant router
#
# Teaches:
# - A router vends a RubyLLM.context per tenant and chats once on each.
# - with_headers is a per-chat override on the station turn.
# - with_context rebinds a global chat onto the cannery tenant without
#   changing RubyLLM.config.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletTenantRouter
  Tenant = Struct.new(:slug, :title, :url, :instructions, :question, keyword_init: true)

  # The overnight desk on Admiralty Inlet hands Point Wilson and the
  # Anacortes cannery each a context, then briefs one question on each.
  class WatchRouter
    STATION = Tenant.new(
      slug: "point-wilson",
      title: "Point Wilson Light Station",
      url: "https://www.nps.gov/places/point-wilson-lighthouse.htm",
      instructions: <<~TEXT.strip,
        You are the outgoing tide clerk at Point Wilson Light Station on Admiralty Inlet.
        Answer in two short sentences.
        Use only the overnight boards in the question.
        Name 07:05 and the horn.
        Do not invent a tide height.
      TEXT
      question: <<~TEXT.strip
        Overnight handover at Point Wilson, Wednesday night 14 October 2026.
        Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
        High water 00:40, 7.6 ft above MLLW.
        Low water 07:05, 1.1 ft.
        Foghorn card: visibility 1 mile, horn running, blast 3 seconds.
        Lens cabinet: closed.
        When is low water, and is the horn running?
      TEXT
    )

    CANNERY = Tenant.new(
      slug: "anacortes-cannery",
      title: "Anacortes Cannery retort desk",
      url: "https://www.portofanacortes.com/",
      instructions: <<~TEXT.strip,
        You are the retort clerk at the Anacortes cannery.
        Answer in two short sentences.
        Use only the cook card in the question.
        Name retort 2 and 242 F.
        Do not invent a basket.
      TEXT
      question: <<~TEXT.strip
        Morning cook card for Wednesday 14 October 2026, retort No. 2.
        Marina: https://www.portofanacortes.com/.
        Posted temperature 242 F.
        Basket 3 of sockeye, lot ANC-314.
        Write the log line for the cannery office.
      TEXT
    )

    TENANTS = {
      STATION.slug => STATION,
      CANNERY.slug => CANNERY
    }.freeze

    Result = Struct.new(
      :station_brief,
      :cannery_log,
      :station_title,
      :cannery_title,
      :station_headers,
      :rebound_context_title,
      :global_title,
      keyword_init: true
    )

    def self.conduct
      configure
      args = Multivitamin::Models.chat(provider: :openrouter)
      router = new

      station_ctx = router.context_for(STATION.slug)
      station_chat = open_chat(station_ctx.chat(**args))
      station_chat.with_instructions(STATION.instructions)
      station_chat.with_temperature(0.2)
      station_chat.with_headers("X-Admiralty-Watch" => "point-wilson-overnight")
      station_brief = station_chat.ask(STATION.question)

      cannery_ctx = router.context_for(CANNERY.slug)
      cannery_chat = open_chat(RubyLLM.chat(**args))
      cannery_chat.with_context(cannery_ctx)
      cannery_chat.with_instructions(CANNERY.instructions)
      cannery_chat.with_temperature(0.2)
      cannery_log = cannery_chat.ask(CANNERY.question)

      Result.new(
        station_brief: station_brief.content,
        cannery_log: cannery_log.content,
        station_title: station_ctx.config.openrouter_app_name,
        cannery_title: cannery_ctx.config.openrouter_app_name,
        station_headers: station_chat.headers,
        rebound_context_title: cannery_chat.context.config.openrouter_app_name,
        global_title: RubyLLM.config.openrouter_app_name
      )
    end

    def self.open_chat(chat)
      Multivitamin::Models.quiet_thinking(chat, provider: :openrouter)
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

    def context_for(slug)
      tenant = TENANTS.fetch(slug)
      RubyLLM.context do |config|
        config.openrouter_app_name = tenant.title
        config.openrouter_app_url = tenant.url
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "watch_router") do
    result = AdmiraltyInletTenantRouter::WatchRouter.conduct
  end

  puts "station (#{result.station_title}):"
  puts result.station_brief
  puts
  puts "cannery (#{result.rebound_context_title}):"
  puts result.cannery_log
end
