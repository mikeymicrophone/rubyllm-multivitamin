# frozen_string_literal: true

# Tools · 05 · Friday Harbor berth desk
#
# Teaches:
# - with_tools adds. A second with_tools keeps the first tool.
# - choice: :required makes the model call a tool and leaves which tool
#   to the model.
# - The berth length is not in the question. The depth tool is a decoy.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborBerthDesk
  class FloatDepth < RubyLLM::Tool
    description "Reads the water depth under the Friday Harbor float. Not the berth length."

    def self.tool_name
      "float_depth"
    end

    def execute
      "Friday Harbor float depth at 14:00 is 11.2 ft."
    end
  end

  class BerthLength < RubyLLM::Tool
    description "Reads the clear fender length of a numbered berth at Friday Harbor"

    def self.tool_name
      "berth_length"
    end

    parameter :berth, type: :integer, description: "Berth number on the Friday Harbor float", required: true

    def execute(berth:)
      return "Berth 7 at Friday Harbor is 54 ft of clear fender." if berth.to_i == 7

      "No length card for berth #{berth}."
    end
  end

  class BerthDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the berth clerk at Friday Harbor.
      Call only the tool that answers the question. Do not call float_depth when the question is about length.
      Answer in one sentence. Include the length the tool returns.
    TEXT

    BERTH_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 at the Friday Harbor float.
      Marina office: https://www.portfridayharbor.org/
      The seiner Kulshan is 48 ft. Does berth 7 have room for her?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_contents, :registered, keyword_init: true)

    def self.conduct
      configure

      chat = open_desk
      chat.with_tool_options(choice: :required)
      answer = chat.ask(BERTH_QUESTION)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        registered: chat.tools.keys
      )
    end

    def self.open_desk
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(FloatDepth)
      chat.with_tools(BerthLength)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "berth_desk") do
    result = FridayHarborBerthDesk::BerthDesk.conduct
  end

  puts result.answer
end
