# frozen_string_literal: true

# Multimodal attachments · 06 · Luang Prabang mural
#
# Teaches:
# - with: takes an array of images in one ask.
# - Each image becomes its own input_image part, in that order.
# - The reply has to use both photographs, not only the first.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LuangPrabangWatMural
  # The painter looks at the west wall, then at the cracked panel.
  class WatMural
    WALL = File.expand_path("mural-wall.png", __dir__)
    PANEL = File.expand_path("panel-five.png", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the mural painter at Wat Xieng Thong in Luang Prabang.
      The first photograph is the west wall.
      The second photograph is the close-up of one panel.
      Answer in one sentence.
      Include the panel count and the number of the cracked panel.
      Do not invent a figure.
    TEXT

    MURAL_QUESTION = "How many panels are on the wall, and which panel must the painter not gild?"

    Result = Struct.new(:report, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      report = chat.ask(MURAL_QUESTION, with: [WALL, PANEL])

      Result.new(
        report: report.content,
        finish: report.finish_reason,
        input_tokens: report.tokens.input,
        cost: report.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      chat.with_temperature(0)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "wat_mural") do
    result = LuangPrabangWatMural::WatMural.conduct
  end

  puts result.report
end
