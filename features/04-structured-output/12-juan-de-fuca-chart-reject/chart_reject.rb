# frozen_string_literal: true

# Structured output · 12 · Juan de Fuca chart reject
#
# Teaches:
# - OpenAI strict mode rejects a schema that marks strict true while a
#   property is left out of required.
# - A required field that may be null uses anyOf of string and null, and
#   stays in required, so strict can stay true.
# - The application rejects a parsed notice that dropped the station.
# - supports?(:structured_output) and supports?(:judgment) are registry
#   checks. whisper-1 has neither. gpt-4.1-mini has structured output and
#   not judgment. gpt-6-luna has both, and judgment is Decisions, not
#   with_schema.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaChartReject
  class MissingStation < StandardError
  end

  # strict: true with bearing optional. OpenAI's Responses API rejects this.
  BROKEN_SCHEMA = {
    name: "ChartCorrection",
    strict: true,
    schema: {
      type: "object",
      properties: {
        station: { type: "string", description: "Light or buoy the notice names" },
        notice: { type: "string", description: "Notice number" },
        bearing: { type: "string", description: "Bearing, only when the notice gives one" }
      },
      required: %w[station notice],
      additionalProperties: false
    }
  }.freeze

  class ChartNotice < Schematist::Schema
    title "chart_notice"
    description "One Juan de Fuca chart correction"

    string :station, description: "The light or buoy the notice names"
    string :notice, description: "Notice number"
    any_of :bearing, description: "Bearing if the notice gives one, otherwise null" do
      string
      null
    end
  end

  class NoticeDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the mate correcting the Juan de Fuca chart.
      Fill the schema from the notice. Copy the station and the notice number.
      The notice gives no bearing, so bearing is null.
    TEXT

    BROKEN_QUESTION = <<~TEXT.strip
      Notice 1842. Station: Ediz Hook. No bearing on this notice.
    TEXT

    NOTICE = <<~TEXT.strip
      Wednesday 14 October 2026, chart desk for the Strait of Juan de Fuca.
      Chart catalog: https://www.nauticalcharts.noaa.gov/
      Notice desk: https://www.navcen.uscg.gov/
      Notice 1842. Station: Ediz Hook.
      Move the bell buoy symbol 0.2 mile west. No bearing is printed.
    TEXT

    Result = Struct.new(
      :rejection_class, :rejection_message, :parsed, :roles, :finish,
      keyword_init: true
    )

    def self.accept_notice(notice)
      station = notice["station"].to_s.strip
      raise MissingStation, "The notice dropped the station" if station.empty?

      notice
    end

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      rejection = nil
      chat.with_schema(BROKEN_SCHEMA)
      begin
        chat.ask(BROKEN_QUESTION)
      rescue RubyLLM::Error => error
        rejection = error
      end

      chat.with_schema(ChartNotice)
      answer = chat.ask(NOTICE)
      accept_notice(answer.parsed)

      Result.new(
        rejection_class: rejection&.class,
        rejection_message: rejection&.message,
        parsed: answer.parsed,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason
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
  Multivitamin::Cassettes.play(__dir__, "chart_reject") do
    result = JuanDeFucaChartReject::NoticeDesk.conduct
  end

  puts "#{result.rejection_class}: #{result.rejection_message}"
  puts JSON.generate(result.parsed)
end
