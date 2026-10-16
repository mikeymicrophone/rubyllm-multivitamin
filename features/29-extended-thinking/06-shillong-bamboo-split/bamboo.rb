# frozen_string_literal: true

# Extended thinking · 06 · Shillong bamboo split
#
# Teaches:
# - A streamed ask with display: :summarized yields chunk.thinking.
# - Joining those deltas equals message.thinking.text.
# - Spoken content still arrives on chunk.content.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ShillongBambooSplit
  class BambooSplit
    INSTRUCTIONS = <<~TEXT.strip
      You are the bamboo clerk in Shillong.
      Answer in one short sentence from the board only.
      The sentence must include the name Bina and the time 11:20.
      Do not replace Bina with a pronoun.
    TEXT

    BOARD = "Board: Bina splits cane SHL-2026-1016-B8 at 11:20. When does Bina split?"

    Result = Struct.new(
      :brief,
      :thinking_text,
      :thinking_pieces,
      :spoken_pieces,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_thinking(effort: :medium, display: :summarized)
      chat.with_instructions(INSTRUCTIONS)
      thinking_pieces = []
      spoken_pieces = []
      brief = chat.ask(BOARD) do |chunk|
        piece = chunk.thinking&.text.to_s
        thinking_pieces << piece unless piece.empty?
        spoken = chunk.content.to_s
        spoken_pieces << spoken unless spoken.empty?
      end
      Result.new(
        brief: brief.content,
        thinking_text: brief.thinking&.text,
        thinking_pieces: thinking_pieces,
        spoken_pieces: spoken_pieces
      )
    end

    def self.open_chat
      RubyLLM.chat(model: Multivitamin::Models::OPENAI_REASONING, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "bamboo") do
    result = ShillongBambooSplit::BambooSplit.conduct
  end

  puts result.brief
  puts "thinking_chunks=#{result.thinking_pieces.size} spoken=#{result.spoken_pieces.size}"
end
