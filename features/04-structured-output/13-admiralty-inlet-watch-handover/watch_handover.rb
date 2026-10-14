# frozen_string_literal: true

# Structured output · 13 · Admiralty Inlet watch handover
#
# Teaches:
# - A schema and a tool can share one chat. The tool supplies the lens
#   crew. The schema is the handover the watch posts.
# - A second ask stays under the same schema.
# - One Judge call can ask a probability and a choice together. RubyLLM
#   sends both questions on a single POST /v1/decisions.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletWatchHandover
  class LensCabinetLatch < RubyLLM::Tool
    description "Reads whether the Point Wilson lens cabinet is shut and who is on the lens crew tonight"

    def self.tool_name
      "lens_cabinet_latch"
    end

    def execute
      "Lens cabinet latch: shut. Tonight's lens crew is Alden. Do not open the cabinet."
    end
  end

  class WatchHandover < Schematist::Schema
    title "watch_handover"
    description "Overnight handover for the Admiralty Inlet watch"

    object :tides, description: "Low water from the question" do
      string :low_clock, description: "Clock time of low water"
      number :low_height_ft, description: "Feet above MLLW"
    end

    array :boats, description: "One object per tender named in the question" do
      object do
        string :name
        string :leaves, description: "Clock time that boat can leave, or holding when it cannot"
      end
    end

    object :lens_crew, description: "From the lens cabinet tool, not from guesswork" do
      string :cabinet, enum: %w[shut open]
      string :tender, description: "The person the lens cabinet tool names"
    end

    string :horn, description: "Blast pattern if the watch has stated one. Until then, exactly not posted."
  end

  class FloatCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    probability :float_clear,
                "Is there at least 6.0 ft of water for a tender to leave the float at the clock in the note?"

    choice :tender, "Which tender should leave the float at the clock in the note?" do
      alden "The foghorn tender Alden"
      retort "The cannery tender Retort"
      neither "Neither tender. The clock is before their leave times, or the water is under 6.0 ft."
    end
  end

  class WatchDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the watch clerk for Admiralty Inlet at Point Wilson.
      Call lens_cabinet_latch once before you fill watch_handover.
      Copy tides and boats from the question.
      Copy the lens cabinet and the lens tender from the tool.
      Set horn to exactly "not posted" until a later message names a blast pattern.
    TEXT

    HANDOVER_QUESTION = <<~TEXT.strip
      Overnight handover, Wednesday 14 October 2026, Point Wilson.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Low water 06:42, 0.4 ft above MLLW.
      Retort can use the float at 08:57.
      Alden needs 6.0 ft and is holding.
      The horn pattern has not been posted on this note.
    TEXT

    HORN_QUESTION = <<~TEXT.strip
      The horn card now says one blast of three seconds.
      Update the handover. Keep the tides, the boats, and the lens crew.
      Set horn to exactly "three-second blast".
    TEXT

    Result = Struct.new(
      :first, :second, :roles, :tool_content, :float_clear, :tender, :tender_probabilities,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(LensCabinetLatch)
      chat.with_tool_options(choice: LensCabinetLatch)
      chat.with_schema(WatchHandover)

      first = chat.ask(HANDOVER_QUESTION)
      second = chat.ask(HORN_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      judgment = FloatCall.judge(<<~TEXT.strip)
        Now is 07:10 at Point Wilson. A tender needs 6.0 ft of water to leave the float.
        #{JSON.generate(second.parsed)}
      TEXT

      Result.new(
        first: first.parsed,
        second: second.parsed,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        float_clear: judgment.float_clear.probability,
        tender: judgment.tender.choice,
        tender_probabilities: judgment.tender.probabilities
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
  Multivitamin::Cassettes.play(__dir__, "watch_handover") do
    result = AdmiraltyInletWatchHandover::WatchDesk.conduct
  end

  puts JSON.generate(result.first)
  puts JSON.generate(result.second)
  puts "float_clear=#{result.float_clear} tender=#{result.tender}"
end
