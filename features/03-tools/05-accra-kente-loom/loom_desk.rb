# frozen_string_literal: true

# Tools · 05 · Accra kente loom desk
#
# Teaches:
# - with_tools adds. A second with_tools keeps the first tool.
# - choice: :required makes the model call a tool and leaves which tool
#   to the model.
# - The remaining warp is not in the question. The reed-sett tool is a decoy.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AccraKenteLoom
  class ReedSett < RubyLLM::Tool
    description "Reads the reed sett on the Bonwire loom. Not the remaining warp length."

    def self.tool_name
      "reed_sett"
    end

    def execute
      "Bonwire reed sett at 14:00 is 11.2 ends per centimetre."
    end
  end

  class ClothLength < RubyLLM::Tool
    description "Reads the remaining warp length of a numbered kente cloth at Bonwire"

    def self.tool_name
      "cloth_length"
    end

    parameter :cloth, type: :integer, description: "Cloth number on the Bonwire loom", required: true

    def execute(cloth:)
      return "Cloth 7 at Bonwire has 54 cm of remaining warp." if cloth.to_i == 7

      "No length card for cloth #{cloth}."
    end
  end

  class LoomDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the loom clerk at Bonwire, outside Accra.
      Call only the tool that answers the question. Do not call reed_sett when the question is about remaining warp.
      Answer in one sentence. Include the length the tool returns.
    TEXT

    LOOM_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026 at the Bonwire kente loft.
      Weaving notes: https://www.ghanamuseums.org/
      Weaver Ama's festival strip is 48 cm. Does cloth 7 have room for her?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_contents, :registered, keyword_init: true)

    def self.conduct
      configure

      chat = open_desk
      chat.with_tool_options(choice: :required)
      answer = chat.ask(LOOM_QUESTION)

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
      chat.with_tools(ReedSett)
      chat.with_tools(ClothLength)
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
  Multivitamin::Cassettes.play(__dir__, "loom_desk") do
    result = AccraKenteLoom::LoomDesk.conduct
  end

  puts result.answer
end
