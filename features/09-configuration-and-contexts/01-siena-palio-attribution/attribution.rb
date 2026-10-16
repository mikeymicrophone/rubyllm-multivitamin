# frozen_string_literal: true

# Configuration and contexts · 01 · Siena Palio attribution headers
#
# Teaches:
# - openrouter_app_url is sent as HTTP-Referer.
# - openrouter_app_name is sent as X-OpenRouter-Title.
# - with_headers adds a contrada header, but provider headers win on
#   HTTP-Referer, so a chat cannot replace the configured attribution.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module SienaPalioAttribution
  # The prova clerk at Contrada della Torre attributes the OpenRouter
  # call to the Comune page, not a tour-desk URL.
  class Attribution
    STATION_URL = "https://www.comune.siena.it/"
    STATION_TITLE = "Contrada della Torre prova desk"
    ATTEMPTED_REFERER = "https://www.sienatours.it/"
    WATCH_HEADER = "overnight-drappellone"

    INSTRUCTIONS = <<~TEXT.strip
      You are the prova clerk at Contrada della Torre in Siena.
      Answer in one short sentence.
      Use only the prova board in the question.
      Name Luce and 19:30.
      Do not invent a race time.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Prova board posted for Wednesday 14 October 2026 at Contrada della Torre, Siena.
      Comune page: https://www.comune.siena.it/
      Horse Luce draws the Torre bridle.
      Jockey Marco walks her at 17:10.
      The evening prova starts at 19:30 in Piazza del Campo.
      When does Luce run tonight?
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
        "X-Siena-Watch" => WATCH_HEADER
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
    result = SienaPalioAttribution::Attribution.conduct
  end

  puts result.brief
end
