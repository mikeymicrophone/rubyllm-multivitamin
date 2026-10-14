# frozen_string_literal: true

# Streaming · 09 · Admiralty Inlet storm warning
#
# Teaches:
# - The inlet's name is read from the joined speech. A chunk may hold only
#   part of it.
# - First-token latency is the time until the first non-empty content chunk.
#   Leading reasoning chunks are not the first spoken token.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletStormWarning
  # The watch at Point Wilson copies a gale warning for Admiralty Inlet.
  # The clock starts when ask starts, and stops at the first spoken chunk.
  class StormWarning
    INSTRUCTIONS = <<~TEXT.strip
      You are the watch at Point Wilson Light Station.
      Speak the warning in one short sentence.
      The sentence must name Admiralty Inlet.
      Use only the warning in the question.
    TEXT

    WARNING_QUESTION = <<~TEXT.strip
      Marine warning copied Wednesday 14 October 2026 for the Point Wilson watch.
      Zone page: https://www.weather.gov/
      Gale warning for Admiralty Inlet.
      Southwest wind 35 knots, gusts 45 knots, through 18:00.
      Small craft stay off the west side of the inlet.
      Speak the warning.
    TEXT

    Note = Struct.new(:content, :thinking, keyword_init: true)

    Result = Struct.new(
      :speech,
      :pieces,
      :notes,
      :started_at,
      :first_spoken_at,
      :finished_at,
      :first_spoken_index,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      notes = []
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      first_spoken_at = nil
      first_spoken_index = nil

      message = chat.ask(WARNING_QUESTION) do |chunk|
        notes << Note.new(content: chunk.content.to_s, thinking: chunk.thinking&.text)
        next unless first_spoken_at.nil? && !chunk.content.to_s.empty?

        first_spoken_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        first_spoken_index = notes.size - 1
      end
      finished_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      Result.new(
        speech: message.content,
        pieces: notes.map(&:content).reject(&:empty?),
        notes: notes,
        started_at: started_at,
        first_spoken_at: first_spoken_at,
        finished_at: finished_at,
        first_spoken_index: first_spoken_index
      )
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "storm_warning") do
    result = AdmiraltyInletStormWarning::StormWarning.conduct
  end

  latency = result.first_spoken_at - result.started_at
  puts result.speech
  puts
  puts "first spoken chunk #{result.first_spoken_index}, latency #{format('%.3f', latency)}s"
end
