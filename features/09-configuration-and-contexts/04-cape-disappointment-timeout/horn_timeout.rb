# frozen_string_literal: true

# Configuration and contexts · 04 · Cape Disappointment request timeout
#
# Teaches:
# - request_timeout on a context is read back from that context's config.
# - RubyLLM.config.request_timeout stays at the global value.
# - ctx.chat still completes a short horn-card turn.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module CapeDisappointmentTimeout
  # The horn house below North Head waits longer than the catalog default
  # for a fog that can sit on the Columbia River bar, without changing the
  # global timeout the rest of the watch uses.
  class HornTimeout
    GLOBAL_TIMEOUT = 120
    HORN_TIMEOUT = 180

    INSTRUCTIONS = <<~TEXT.strip
      You are the foghorn tender at Cape Disappointment, in the horn house
      below North Head.
      Copy the timing card in two short sentences.
      Use only the card in the question.
      Include 2 seconds and 18 seconds.
      Do not describe the park.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Timing card posted in the horn house at Cape Disappointment.
      Park page: https://parks.wa.gov/find-parks/state-parks/cape-disappointment-state-park.
      Blast 2 seconds.
      Silent 18 seconds.
      The horn is the diaphone.
      Write the slate for the watch.
    TEXT

    Result = Struct.new(
      :slate,
      :horn_timeout,
      :global_timeout,
      keyword_init: true
    )

    def self.conduct
      configure
      horn = RubyLLM.context do |config|
        config.request_timeout = HORN_TIMEOUT
      end
      chat = open_chat(horn)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      slate = chat.ask(CARD_QUESTION)

      Result.new(
        slate: slate.content,
        horn_timeout: horn.config.request_timeout,
        global_timeout: RubyLLM.config.request_timeout
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
        config.max_retries = 0
        config.request_timeout = GLOBAL_TIMEOUT
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "horn_timeout") do
    result = CapeDisappointmentTimeout::HornTimeout.conduct
  end

  puts "timeout #{result.horn_timeout} (global #{result.global_timeout}):"
  puts result.slate
end
