# frozen_string_literal: true

# Tools · 03 · Cape Disappointment compressor
#
# Teaches:
# - parameter declares a type, a description, and required.
# - A number stays a number in the schema. The posted minimum is not
#   in the question. The tool is what compares the gauge.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentCompressor
  # The gauge reading comes from the watch. The posted minimum lives here.
  class CompressorCard < RubyLLM::Tool
    description "Compares a foghorn compressor gauge with the posted minimum at Cape Disappointment"

    def self.tool_name
      "compressor_card"
    end

    parameter :psi, type: :number, description: "Compressor pressure in psi from the gauge", required: true
    parameter :station, type: :string, description: "Horn station the gauge belongs to", required: true

    POSTED_MINIMUM_PSI = 85

    def execute(psi:, station:)
      reading = psi.to_f
      verdict = reading >= POSTED_MINIMUM_PSI ? "clears" : "is below"
      "#{station} compressor at #{reading} psi #{verdict} the #{POSTED_MINIMUM_PSI} psi posted minimum."
    end
  end

  class GaugeCheck
    INSTRUCTIONS = <<~TEXT.strip
      You are the foghorn watch at Cape Disappointment Light.
      Call compressor_card with the station and the psi from the question.
      Answer in one sentence. Include the posted minimum the tool names and whether the gauge clears it.
    TEXT

    GAUGE_QUESTION = <<~TEXT.strip
      Horn watch at Cape Disappointment, Wednesday 14 October 2026.
      Headland notes: https://parks.wa.gov/find-parks/state-parks/cape-disappointment-state-park
      The gauge on the compressor reads 92 psi.
      Does this station's compressor clear the posted minimum?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)
      chat.with_tools(CompressorCard)
      chat.with_tool_options(choice: CompressorCard)

      answer = chat.ask(GAUGE_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content
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
  Multivitamin::Cassettes.play(__dir__, "compressor_card") do
    result = CapeDisappointmentCompressor::GaugeCheck.conduct
  end

  puts result.answer
end
