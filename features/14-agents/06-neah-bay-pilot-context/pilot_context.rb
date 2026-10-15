# frozen_string_literal: true

# Agents · 06 · Neah Bay pilot context
#
# Teaches:
# - A zero-argument context block defers until the chat is built, copying
#   the configured key and overlaying the boat's OpenRouter title.
# - The agent's chats send that title. The global config does not keep the
#   boat's name.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NeahBayPilotContext
  class PilotClerk < RubyLLM::Agent
    model "openai/gpt-4.1-mini", provider: :openrouter, assume_model_exists: true
    temperature 0.2
    max_output_tokens 512

    instructions <<~TEXT.strip
      You are the mate on the pilot boat Alden, boarding ships off Neah Bay.
      Answer in two short sentences from the ladder notes only.
      The first sentence starts with Yes or No.
      Do not invent ladder lengths.
    TEXT

    # Zero-argument form defers until the chat is built, so the isolated
    # copy includes the key configure() just set. An arity-1 block would
    # snapshot at class load, before that key exists.
    context do
      RubyLLM.context do |config|
        config.openrouter_app_name = "Neah Bay pilot boat Alden"
        config.openrouter_app_url = "https://www.navcen.uscg.gov/"
        config.request_timeout = 90
      end
    end
  end

  class LadderBrief
    GLOBAL_TITLE = "RubyLLM Multivitamin"
    BOAT_TITLE = "Neah Bay pilot boat Alden"
    BOAT_URL = "https://www.navcen.uscg.gov/"

    LADDER_QUESTION = <<~TEXT.strip
      Boarding the bulk carrier Silver Kelp off Neah Bay.
      The chart on the pilot's clipboard is from https://www.nauticalcharts.noaa.gov/.
      Rigged ladder: 9 meters of side ropes, wooden steps, manropes on both sides.
      Embarkation deck: 8.4 meters above the water.
      The pilot boat's rail sits 1.5 meters above the water.
      Is the rigged 9 meter ladder long enough?
    TEXT

    Result = Struct.new(
      :brief,
      :roles,
      :global_title_after,
      :global_timeout_after,
      :agent_timeout,
      keyword_init: true
    )

    def self.conduct
      configure
      agent = open_agent
      brief = agent.ask(LADDER_QUESTION)

      Result.new(
        brief: brief.content,
        roles: agent.messages.map(&:role),
        global_title_after: RubyLLM.config.openrouter_app_name,
        global_timeout_after: RubyLLM.config.request_timeout,
        agent_timeout: agent.context.config.request_timeout
      )
    end

    def self.open_agent
      PilotClerk.new
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.openrouter_app_name = GLOBAL_TITLE
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
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
  Multivitamin::Cassettes.play(__dir__, "pilot_context") do
    result = NeahBayPilotContext::LadderBrief.conduct
  end

  puts result.brief
end
