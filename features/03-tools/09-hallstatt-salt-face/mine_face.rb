# frozen_string_literal: true

# Tools · 09 · Hallstatt salt-mine face
#
# Teaches:
# - The station the tool needs can sit later in the question. The first
#   sentence names the visitor office, not the face.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HallstattSaltFace
  class FaceCard < RubyLLM::Tool
    description "Reads the face-depth card for an Alpine salt mine"

    def self.tool_name
      "face_card"
    end

    parameter :station, type: :string, description: "Mine station, such as Hallstatt", required: true

    HALLSTATT_CARD = "The face at Hallstatt Kaiserin Elisabeth is 38 m at 10:30 on 15 October 2026."

    def execute(station:)
      return HALLSTATT_CARD if station.to_s.match?(/hallstatt/i)

      "No face card for #{station}."
    end
  end

  class FaceReading
    INSTRUCTIONS = <<~TEXT.strip
      You are the face clerk at the Hallstatt salt mine.
      Call face_card with the mine station named in the question.
      Answer in one sentence and include the depth the tool returns.
    TEXT

    FACE_QUESTION = <<~TEXT.strip
      The Salzburg visitor office is holding a school group on the platform.
      Mine office: https://whc.unesco.org/en/list/806/
      The group needs the face depth at Hallstatt before the 11:00 descent.
      Read the face card for that station.
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :station, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(FaceCard)
      chat.with_tool_options(choice: FaceCard)

      answer = chat.ask(FACE_QUESTION)
      tool_call = chat.messages.find(&:tool_call?)&.tool_calls&.values&.first
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        station: tool_call&.arguments&.fetch("station")
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
  Multivitamin::Cassettes.play(__dir__, "mine_face") do
    result = HallstattSaltFace::FaceReading.conduct
  end

  puts result.answer
end
