# frozen_string_literal: true

# Streaming · 09 · Christchurch Alpine Fault warning
#
# Teaches:
# - The fault's name is read from the joined speech. A chunk may hold only
#   part of it.
# - First-token latency is the time until the first non-empty content chunk.
#   Leading reasoning chunks, when the model streams them, are not the
#   first spoken token. gpt-4.1-mini often speaks on the first chunk.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ChristchurchFaultWarning
  # The civic desk in Christchurch copies a shaking warning for the Alpine
  # Fault. The clock starts when ask starts, and stops at the first spoken
  # chunk.
  class FaultWarning
    INSTRUCTIONS = <<~TEXT.strip
      You are the civic desk at Christchurch City Council.
      Speak the warning in one short sentence.
      The sentence must name Alpine Fault.
      Use only the warning in the question.
    TEXT

    WARNING_QUESTION = <<~TEXT.strip
      Seismic warning copied Wednesday 14 October 2026 for the Christchurch civic desk.
      GeoNet page: https://www.geonet.org.nz/
      Shake warning for Alpine Fault.
      Expected intensity 8, 35 schools close, through 18:00.
      Hold assemblies off the west side of the fault.
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
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "fault_warning") do
    result = ChristchurchFaultWarning::FaultWarning.conduct
  end

  latency = result.first_spoken_at - result.started_at
  puts result.speech
  puts
  puts "first spoken chunk #{result.first_spoken_index}, latency #{format('%.3f', latency)}s"
end
