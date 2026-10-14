# frozen_string_literal: true

# Configuration and contexts · 07 · Neah Bay retry knobs
#
# Teaches:
# - max_retries, retry_interval, and retry_backoff_factor are per context.
# - The boarding context sets max_retries to 0 so a cassette is one POST.
# - The global retry count stays at the catalog default.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module NeahBayRetryKnobs
  # The mate on the pilot boat Alden, boarding off Neah Bay, turns retries
  # off on the boarding context so a failed ladder check is not posted twice.
  class PilotRetries
    GLOBAL_RETRIES = 3
    BOARDING_RETRIES = 0
    BOARDING_INTERVAL = 1.0
    BOARDING_BACKOFF = 1.5

    INSTRUCTIONS = <<~TEXT.strip
      You are the mate on the pilot boat Alden, boarding ships off Neah Bay.
      Answer in two short sentences.
      Use only the ladder notes in the question.
      The first sentence starts with Yes or No.
      Do not invent a ladder length.
    TEXT

    LADDER_QUESTION = <<~TEXT.strip
      Boarding the bulk carrier Silver Kelp off Neah Bay.
      Chart catalog: https://www.nauticalcharts.noaa.gov/.
      Light list: https://www.navcen.uscg.gov/.
      Rigged ladder: 9 meters of side ropes.
      Embarkation deck: 8.4 meters above the water.
      The pilot boat's rail sits 1.5 meters above the water.
      Is the rigged 9 meter ladder long enough to reach the rail?
    TEXT

    Result = Struct.new(
      :ladder,
      :boarding_retries,
      :boarding_interval,
      :boarding_backoff,
      :global_retries,
      :global_interval,
      keyword_init: true
    )

    def self.conduct
      configure
      boarding = RubyLLM.context do |config|
        config.max_retries = BOARDING_RETRIES
        config.retry_interval = BOARDING_INTERVAL
        config.retry_backoff_factor = BOARDING_BACKOFF
        config.retry_interval_randomness = 0.0
      end
      chat = open_chat(boarding)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      ladder = chat.ask(LADDER_QUESTION)

      Result.new(
        ladder: ladder.content,
        boarding_retries: boarding.config.max_retries,
        boarding_interval: boarding.config.retry_interval,
        boarding_backoff: boarding.config.retry_backoff_factor,
        global_retries: RubyLLM.config.max_retries,
        global_interval: RubyLLM.config.retry_interval
      )
    end

    def self.open_chat(context)
      ConfigurationPaidOpenrouter.prepare(
        context.chat(**ConfigurationPaidOpenrouter.chat_args)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = GLOBAL_RETRIES
        config.retry_interval = 0.1
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "pilot_retries") do
    result = NeahBayRetryKnobs::PilotRetries.conduct
  end

  puts "retries #{result.boarding_retries} interval #{result.boarding_interval}:"
  puts result.ladder
end
