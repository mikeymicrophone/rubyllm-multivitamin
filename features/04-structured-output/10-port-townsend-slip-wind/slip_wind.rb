# frozen_string_literal: true

# Structured output · 10 · Port Townsend slip wind
#
# Teaches:
# - ask with a block streams a schema the same way it streams prose.
# - Chunk content is a piece of the JSON text. Joining the pieces equals
#   message.content. message.parsed is the Hash, and its keys are strings.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendSlipWind
  class WindReport < Schematist::Schema
    title "wind_report"
    description "Wind at the Port Townsend ferry slip"

    string :direction, description: "Wind direction word from the board"
    integer :knots, description: "Sustained wind in knots"
    integer :gusts, description: "Gust speed in knots"
  end

  class SlipWind
    INSTRUCTIONS = <<~TEXT.strip
      You are the slip watch at the Port Townsend ferry terminal.
      Fill wind_report from the board. Copy the numbers as integers.
    TEXT

    BOARD = <<~TEXT.strip
      Port Townsend ferry slip, Wednesday 14 October 2026, 07:40.
      Terminal page: https://wsdot.wa.gov/ferries
      Wind southwest at 18 knots, gusts 24.
    TEXT

    Result = Struct.new(:content, :parsed, :pieces, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(WindReport)

      pieces = []
      answer = chat.ask(BOARD) do |chunk|
        pieces << chunk.content
      end

      Result.new(
        content: answer.content,
        parsed: answer.parsed,
        pieces: pieces,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "slip_wind") do
    result = PortTownsendSlipWind::SlipWind.conduct
  end

  puts result.content
  puts JSON.generate(result.parsed)
  puts "pieces=#{result.pieces.size}"
end
