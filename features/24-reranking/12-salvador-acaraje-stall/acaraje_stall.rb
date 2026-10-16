# frozen_string_literal: true

# Reranking · 12 · Salvador acarajé stall
#
# Teaches:
# - Rerank the stall cards, then ask the chat about the winner.
# - This is the neighbor-pipeline shape without pgvector.
# - The cassette is rerank then Responses.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SalvadorAcarajeStall
  class AcarajeStall
    QUERY = "Which stall fries the morning acarajé for Dona Lúcia?"

    STALLS = [
      "Stall 1, vatapá only, no frying this morning.",
      "Stall 4, Dona Lúcia's acarajé, first oil at 07:20, Salvador.",
      "Stall 6, dried shrimp bags, not a fryer.",
      "Stall 9, afternoon moqueca, closed until 16:00."
    ].freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the market clerk in Salvador.
      Answer in one short sentence from the winning stall card only.
      Name Lúcia and 07:20.
    TEXT

    Result = Struct.new(:index, :brief, :roles, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, STALLS, **Multivitamin::Models.rerank, top_n: 1)
      winner = ranked.results.first

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      message = chat.ask(winner.document)

      Result.new(
        index: winner.index,
        brief: message.content,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "acaraje_stall") do
    result = SalvadorAcarajeStall::AcarajeStall.conduct
  end

  puts "index=#{result.index}"
  puts result.brief
end
