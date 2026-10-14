# frozen_string_literal: true

# Tools · 10 · Port Townsend slip wind
#
# Teaches:
# - with_tool_options(calls: :many) sends parallel_tool_calls true so one
#   assistant turn can carry two calls.
# - A Hash return is JSON on the tool message. A String return, as on the
#   tide board, is not.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendSlipWind
  class SlipAnemometer < RubyLLM::Tool
    description "Reads one anemometer mast at the Port Townsend ferry slip. Call once per mast."

    def self.tool_name
      "slip_anemometer"
    end

    parameter :mast, type: :string, description: "north or south mast", required: true

    READINGS = {
      "north" => { "mast" => "north", "knots" => 18, "gust" => 27 },
      "south" => { "mast" => "south", "knots" => 22, "gust" => 31 }
    }.freeze

    def execute(mast:)
      READINGS.fetch(mast.to_s.downcase) { { "error" => "No anemometer named #{mast}." } }
    end
  end

  class MastRound
    INSTRUCTIONS = <<~TEXT.strip
      You are the slip watch at Port Townsend.
      Call slip_anemometer twice in one response, once for the north mast and once for the south mast.
      Then answer in one sentence that includes both gusts.
    TEXT

    WIND_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, wind round at the Port Townsend ferry slip.
      Terminal page: https://wsdot.wa.gov/ferries
      Read the north mast and the south mast.
    TEXT

    Result = Struct.new(:answer, :roles, :tool_contents, :call_count, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)
      chat.with_tools(SlipAnemometer)
      chat.with_tool_options(choice: SlipAnemometer, calls: :many)

      answer = chat.ask(WIND_QUESTION)
      tool_turn = chat.messages.find(&:tool_call?)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        call_count: tool_turn&.tool_calls&.size
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
  Multivitamin::Cassettes.play(__dir__, "slip_wind") do
    result = PortTownsendSlipWind::MastRound.conduct
  end

  puts result.answer
end
