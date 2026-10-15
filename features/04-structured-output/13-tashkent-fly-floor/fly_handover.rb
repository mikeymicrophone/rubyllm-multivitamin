# frozen_string_literal: true

# Structured output · 13 · Tashkent fly-floor handover
#
# Teaches:
# - A schema and a tool can share one chat. The tool supplies the costume
#   crew. The schema is the handover the fly floor posts.
# - A second ask stays under the same schema.
# - One Judge call can ask a probability and a choice together. RubyLLM
#   sends both questions on a single POST /v1/decisions.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TashkentFlyFloor
  class CostumeCabinetLatch < RubyLLM::Tool
    description "Reads whether the Navoi costume cabinet is shut and who is on the dresser crew tonight"

    def self.tool_name
      "costume_cabinet_latch"
    end

    def execute
      "Costume cabinet latch: shut. Tonight's dresser is Nigora. Do not open the cabinet."
    end
  end

  class FlyHandover < Schematist::Schema
    title "fly_handover"
    description "Overnight handover for the Alisher Navoi fly floor"

    object :curtain, description: "Low fly from the question" do
      string :low_clock, description: "Clock time of the low fly"
      number :low_height_m, description: "Metres of fly remaining"
    end

    array :companies, description: "One object per company named in the question" do
      object do
        string :name
        string :leaves, description: "Clock time that company can leave, or holding when it cannot"
      end
    end

    object :fly_crew, description: "From the costume cabinet tool, not from guesswork" do
      string :cabinet, enum: %w[shut open]
      string :dresser, description: "The person the costume cabinet tool names"
    end

    string :overture, description: "Overture sting if the floor has stated one. Until then, exactly not posted."
  end

  class DeckCall < RubyLLM::Judge
    model Multivitamin::Models::OPENAI_JUDGMENT, provider: :openai

    probability :deck_clear,
                "Is there at least 6.0 m of fly for a company to leave the deck at the clock in the note?"

    choice :company, "Which company should leave the deck at the clock in the note?" do
      navoi "The Navoi company"
      ilkhom "The Ilkhom company"
      neither "Neither company. The clock is before their leave times, or the fly is under 6.0 m."
    end
  end

  class FlyDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the fly-floor clerk at the Alisher Navoi Opera and Ballet Theatre in Tashkent.
      Call costume_cabinet_latch once before you fill fly_handover.
      Copy curtain and companies from the question.
      Copy the costume cabinet and the dresser from the tool.
      Set overture to exactly "not posted" until a later message names a sting.
    TEXT

    HANDOVER_QUESTION = <<~TEXT.strip
      Overnight handover, Wednesday 14 October 2026, Alisher Navoi Theatre, Tashkent.
      House notes: https://gabt.uz/
      Low fly 06:42, 0.4 m remaining.
      Ilkhom can use the deck at 08:57.
      Navoi needs 6.0 m and is holding.
      The overture sting has not been posted on this note.
    TEXT

    STING_QUESTION = <<~TEXT.strip
      The overture card now says one blast of three seconds.
      Update the handover. Keep the curtain, the companies, and the fly crew.
      Set overture to exactly "three-second blast".
    TEXT

    Result = Struct.new(
      :first, :second, :roles, :tool_content, :deck_clear, :company, :company_probabilities,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(CostumeCabinetLatch)
      chat.with_tool_options(choice: CostumeCabinetLatch)
      chat.with_schema(FlyHandover)

      first = chat.ask(HANDOVER_QUESTION)
      second = chat.ask(STING_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      judgment = DeckCall.judge(<<~TEXT.strip)
        Now is 07:10 at the Alisher Navoi Theatre. A company needs 6.0 m of fly to leave the deck.
        #{JSON.generate(second.parsed)}
      TEXT

      Result.new(
        first: first.parsed,
        second: second.parsed,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        deck_clear: judgment.deck_clear.probability,
        company: judgment.company.choice,
        company_probabilities: judgment.company.probabilities
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
  Multivitamin::Cassettes.play(__dir__, "fly_handover") do
    result = TashkentFlyFloor::FlyDesk.conduct
  end

  puts JSON.generate(result.first)
  puts JSON.generate(result.second)
  puts "deck_clear=#{result.deck_clear} company=#{result.company}"
end
