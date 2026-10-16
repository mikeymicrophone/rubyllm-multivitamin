# frozen_string_literal: true

# Evaluations · 04 · Toledo damascene-wire tool
#
# Teaches:
# - perform may force a tool so the conversation holds a tool turn.
# - The grader still sees the spoken answer. tool_calls sit on the evidence.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ToledoDamasceneWire
  class PostedDamasceneCard < RubyLLM::Tool
    description "Reads the damascene wire card posted at the Toledo yard"

    def self.tool_name
      "posted_damascene_card"
    end

    CARD = <<~TEXT.strip
      Toledo damascene card for Friday 16 October 2026.
      Bed TD-South, 14 wires, cart Inés alongside at 07:10.
    TEXT

    def execute
      CARD
    end
  end

  class WireCount < RubyLLM::Evaluation
    dataset File.expand_path("damascene_wire.yml", __dir__)
    evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

    INSTRUCTIONS = <<~TEXT.strip
      You are the wire clerk at the damascene yard in Toledo.
      Call posted_damascene_card once. Then answer in two short sentences.
      Include the wire count and the cart name from the card.
    TEXT

    def perform(input)
      chat = self.class.open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_tools(PostedDamasceneCard)
      chat.with_tool_options(choice: PostedDamasceneCard)
      chat.ask(input)
    end

    def self.conduct
      configure
      run
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

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end
  end
end

if $PROGRAM_NAME == __FILE__
  report = nil
  Multivitamin::Cassettes.play(__dir__, "damascene_wire") do
    report = ToledoDamasceneWire::WireCount.conduct
  end
  puts report
end
