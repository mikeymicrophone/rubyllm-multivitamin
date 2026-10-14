# frozen_string_literal: true

# Tools · 11 · Port Angeles net loft
#
# Teaches:
# - with_tool_options(choice:) can force one tool while another stays
#   registered.
# - After that forced call runs, RubyLLM clears the choice so the model
#   can answer without calling it again.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortAngelesNetLoft
  class TwineStock < RubyLLM::Tool
    description "Counts spools of tarred nylon at the Port Angeles net loft"

    def self.tool_name
      "twine_stock"
    end

    parameter :size, type: :string, description: "Twine size, such as No. 18", required: true

    def execute(size:)
      return "No. 18 tarred nylon at the Port Angeles net loft: 14 spools." if size.to_s.include?("18")

      "No spool count for #{size}."
    end
  end

  class NeedleGauge < RubyLLM::Tool
    description "Reads the mending needle length at the Port Angeles net loft"

    def self.tool_name
      "needle_gauge"
    end

    def execute
      "The mending needles at the Port Angeles net loft are 6 inch."
    end
  end

  class TwineTicket
    INSTRUCTIONS = <<~TEXT.strip
      You are the net loft clerk at Port Angeles.
      Call twine_stock for the twine size in the question.
      Do not call needle_gauge.
      Answer in one sentence about the spools. Say the needle gauge was not read on this ticket.
    TEXT

    TICKET_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, mending ticket at the Port Angeles net loft.
      Marina: https://www.portofpa.com/
      How many spools of No. 18 tarred nylon are on the shelf, and what size are the needles?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_contents, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(TwineStock, NeedleGauge)
      chat.with_tool_options(choice: TwineStock)

      answer = chat.ask(TICKET_QUESTION)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content)
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
  Multivitamin::Cassettes.play(__dir__, "twine_stock") do
    result = PortAngelesNetLoft::TwineTicket.conduct
  end

  puts result.answer
end
