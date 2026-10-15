# frozen_string_literal: true

# Tool approval and loop control · 10 · Tahuya ten-step budget
#
# Teaches:
# - Cap a runaway tool loop with a step budget, not by raising inside a
#   callback.
# - After ten steps the transcript is still valid. complete? is false.
#   Calling step again resumes where the budget stopped.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TahuyaTenStepBudget
  class SoundingPole < RubyLLM::Tool
    description "Takes the next sounding at Tahuya spit. Call again for the next mark."

    def self.tool_name
      "sounding_pole"
    end

    def self.reset!
      @mark = 0
    end

    def self.mark
      @mark
    end

    def execute
      self.class.instance_variable_set(:@mark, self.class.mark + 1)
      n = self.class.mark
      "Tahuya spit sounding #{n} of 20: #{20 - n} ft at the pole. Call sounding_pole again for the next mark."
    end
  end

  class SpitWatch
    BUDGET = 10

    INSTRUCTIONS = <<~TEXT.strip
      You are the sounding watch at Tahuya spit.
      Keep calling sounding_pole until the pole reports sounding 20 of 20.
      Do not stop early. Do not invent a depth.
    TEXT

    SPIT_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, sounding round at Tahuya spit.
      Canal notes: https://www.charts.noaa.gov/
      Walk the pole out to sounding 20 and post every mark.
    TEXT

    Result = Struct.new(
      :steps,
      :settled,
      :marks,
      :tool_count,
      :resumed_mark,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      SoundingPole.reset!

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(SoundingPole)

      chat.ask_later(SPIT_QUESTION)
      steps = 0
      BUDGET.times do
        break if chat.complete? || chat.waiting?

        chat.with_tool_options(choice: SoundingPole) unless chat.messages.last&.tool_call?
        chat.step
        steps += 1
      end

      marks = SoundingPole.mark
      settled = chat.complete?
      tool_count = chat.messages.count { |message| message.role == :tool }

      4.times do
        break if SoundingPole.mark > marks || chat.complete? || chat.waiting?

        chat.with_tool_options(choice: SoundingPole) unless chat.messages.last&.tool_call?
        chat.step
      end

      Result.new(
        steps: steps,
        settled: settled,
        marks: marks,
        tool_count: tool_count,
        resumed_mark: SoundingPole.mark,
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "sounding_pole") do
    result = TahuyaTenStepBudget::SpitWatch.conduct
  end

  puts "#{result.steps} steps, #{result.marks} marks, resumed #{result.resumed_mark}"
end
