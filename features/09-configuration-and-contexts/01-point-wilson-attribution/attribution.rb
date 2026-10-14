# frozen_string_literal: true

# Configuration and contexts · 01 · Point Wilson attribution headers
#
# Teaches:
# - openrouter_app_url is sent as HTTP-Referer.
# - openrouter_app_name is sent as X-OpenRouter-Title.
# - with_headers adds a station header, but provider headers win on
#   HTTP-Referer, so a chat cannot replace the configured attribution.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module PointWilsonAttribution
  # The tide clerk at Point Wilson Light Station attributes the OpenRouter
  # call to the station page, not the catalog's GitHub URL.
  class Attribution
    STATION_URL = "https://www.nps.gov/places/point-wilson-lighthouse.htm"
    STATION_TITLE = "Point Wilson Light Station"
    ATTEMPTED_REFERER = "https://www.portoftacoma.com/"
    WATCH_HEADER = "overnight-kelp-ledge"

    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Point Wilson Light Station on Admiralty Inlet.
      Answer in one short sentence.
      Use only the tide board in the question.
      Name Alden and 10:46.
      Do not invent a tide height.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Tide board posted for Wednesday 14 October 2026 at Point Wilson.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      High water 12:18, 8.1 ft.
      Alden clears the kelp ledge at 10:46.
      When can Alden leave the float this morning?
    TEXT

    Result = Struct.new(
      :brief,
      :headers,
      :model_id,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_headers(
        "HTTP-Referer" => ATTEMPTED_REFERER,
        "X-Point-Wilson-Watch" => WATCH_HEADER
      )
      brief = chat.ask(BOARD_QUESTION)

      Result.new(
        brief: brief.content,
        headers: chat.headers,
        model_id: brief.model
      )
    end

    def self.open_chat
      ConfigurationPaidOpenrouter.prepare(
        RubyLLM.chat(**ConfigurationPaidOpenrouter.chat_args)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.openrouter_app_url = STATION_URL
        config.openrouter_app_name = STATION_TITLE
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
  Multivitamin::Cassettes.play(__dir__, "attribution") do
    result = PointWilsonAttribution::Attribution.conduct
  end

  puts result.brief
end
