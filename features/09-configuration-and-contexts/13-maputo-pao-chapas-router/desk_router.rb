# frozen_string_literal: true

# Configuration and contexts · 13 · Maputo pão and chapas router
#
# Teaches:
# - A router vends a RubyLLM.context per tenant and chats once on each.
# - with_headers is a per-chat override on the bakery turn.
# - with_context rebinds a global chat onto the chapas tenant without
#   changing RubyLLM.config.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module MaputoPaoChapasRouter
  Tenant = Struct.new(:slug, :title, :url, :instructions, :question, keyword_init: true)

  # The overnight desk in Maputo hands Padaria da Beira and the Junta
  # chapas rank each a context, then briefs one question on each.
  class DeskRouter
    BAKERY = Tenant.new(
      slug: "padaria-da-beira",
      title: "Padaria da Beira oven desk",
      url: "https://www.cmmaputo.gov.mz/",
      instructions: <<~TEXT.strip,
        You are the outgoing oven clerk at Padaria da Beira in Maputo.
        Answer in two short sentences.
        Use only the overnight boards in the question.
        Name 07:05 and the oven.
        Do not invent a loaf count.
      TEXT
      question: <<~TEXT.strip
        Overnight handover at Padaria da Beira, Wednesday night 14 October 2026.
        Bakery street: Avenida 24 de Julho, Maputo.
        First bake 00:40, 76 pão da Beira.
        Second bake 07:05, 11 pão de ló.
        Oven card: wood low, oven running, door 3 minutes.
        Sugar bin: closed.
        When is the second bake, and is the oven running?
      TEXT
    )

    RANK = Tenant.new(
      slug: "terminal-da-junta",
      title: "Terminal da Junta chapas rank",
      url: "https://www.cmmaputo.gov.mz/transportes",
      instructions: <<~TEXT.strip,
        You are the rank clerk at Terminal da Junta in Maputo.
        Answer in two short sentences.
        Use only the fare card in the question.
        Name chapas 42 and 12.
        Do not invent a fare.
      TEXT
      question: <<~TEXT.strip
        Morning fare card for Wednesday 14 October 2026, Terminal da Junta.
        Rank page: https://www.cmmaputo.gov.mz/transportes.
        Posted fare 12 meticais.
        Chapas 42 to Costa do Sol, lot JUN-314.
        Write the log line for the rank office.
      TEXT
    )

    TENANTS = {
      BAKERY.slug => BAKERY,
      RANK.slug => RANK
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
      args = ConfigurationPaidOpenrouter.chat_args
      router = new

      station_ctx = router.context_for(BAKERY.slug)
      station_chat = open_chat(station_ctx.chat(**args))
      station_chat.with_instructions(BAKERY.instructions)
      station_chat.with_temperature(0.2)
      station_chat.with_headers("X-Maputo-Desk" => "padaria-overnight")
      station_brief = station_chat.ask(BAKERY.question)

      cannery_ctx = router.context_for(RANK.slug)
      cannery_chat = open_chat(RubyLLM.chat(**args))
      cannery_chat.with_context(cannery_ctx)
      cannery_chat.with_instructions(RANK.instructions)
      cannery_chat.with_temperature(0.2)
      cannery_log = cannery_chat.ask(RANK.question)

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
      ConfigurationPaidOpenrouter.prepare(chat)
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
  Multivitamin::Cassettes.play(__dir__, "desk_router") do
    result = MaputoPaoChapasRouter::DeskRouter.conduct
  end

  puts "bakery (#{result.station_title}):"
  puts result.station_brief
  puts
  puts "rank (#{result.rebound_context_title}):"
  puts result.cannery_log
end
