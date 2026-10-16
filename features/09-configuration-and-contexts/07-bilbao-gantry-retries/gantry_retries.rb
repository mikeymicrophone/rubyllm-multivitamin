# frozen_string_literal: true

# Configuration and contexts · 07 · Bilbao gantry retry knobs
#
# Teaches:
# - max_retries, retry_interval, and retry_backoff_factor are per context.
# - The torque context sets max_retries to 0 so a cassette is one POST.
# - The global retry count stays at the catalog default.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module BilbaoGantryRetries
  # The fitter Aitor on the Zorrotzaurre gantry turns retries off on the
  # torque context so a failed bolt check is not posted twice.
  class GantryRetries
    GLOBAL_RETRIES = 3
    TORQUE_RETRIES = 0
    TORQUE_INTERVAL = 1.0
    TORQUE_BACKOFF = 1.5

    INSTRUCTIONS = <<~TEXT.strip
      You are the crane fitter Aitor on the Zorrotzaurre gantry in Bilbao.
      Answer in two short sentences.
      Use only the torque notes in the question.
      The first sentence starts with Yes or No.
      Do not invent a torque figure.
    TEXT

    TORQUE_QUESTION = <<~TEXT.strip
      Torque check on the Nervión gantry at Zorrotzaurre, Bilbao.
      Yard page: https://www.bilbao.eus/.
      Posted wrench reading: 420 newton-metres.
      M30 flange bolts are rated 400 newton-metres minimum.
      The next lift is the coil cradle at 07:20.
      Is the posted 420 newton-metre reading enough for the M30 bolts?
    TEXT

    Result = Struct.new(
      :torque,
      :boarding_retries,
      :boarding_interval,
      :boarding_backoff,
      :global_retries,
      :global_interval,
      keyword_init: true
    )

    def self.conduct
      configure
      torque_ctx = RubyLLM.context do |config|
        config.max_retries = TORQUE_RETRIES
        config.retry_interval = TORQUE_INTERVAL
        config.retry_backoff_factor = TORQUE_BACKOFF
        config.retry_interval_randomness = 0.0
      end
      chat = open_chat(torque_ctx)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      torque = chat.ask(TORQUE_QUESTION)

      Result.new(
        torque: torque.content,
        boarding_retries: torque_ctx.config.max_retries,
        boarding_interval: torque_ctx.config.retry_interval,
        boarding_backoff: torque_ctx.config.retry_backoff_factor,
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
  Multivitamin::Cassettes.play(__dir__, "gantry_retries") do
    result = BilbaoGantryRetries::GantryRetries.conduct
  end

  puts "retries #{result.boarding_retries} interval #{result.boarding_interval}:"
  puts result.torque
end
