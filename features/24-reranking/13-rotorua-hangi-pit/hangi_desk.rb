# frozen_string_literal: true

# Reranking · 13 · Rotorua hāngī pit
#
# Teaches:
# - Capstone: eight pit cards, top_n 3, index back to the pit structs,
#   then a brief of the winner.
# - Tokens sit on the ranked object when Voyage reports them.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module RotoruaHangiPit
  Pit = Struct.new(:pit, :kai, :note, keyword_init: true)

  class HangiDesk
    PITS = [
      Pit.new(pit: "A", kai: "kumara", note: "Pit A, kumara only, too small for the school hāngī."),
      Pit.new(pit: "B", kai: "pork", note: "Pit B, pork and cabbage, closed until dusk."),
      Pit.new(pit: "C", kai: "chicken", note: "Pit C, chicken parcels, not the school basket."),
      Pit.new(pit: "D", kai: "school basket", note: "Pit D, school hāngī basket, chicken and kumara, stones at 11:40, Rotorua."),
      Pit.new(pit: "E", kai: "mutton", note: "Pit E, mutton, visitor group."),
      Pit.new(pit: "F", kai: "empty", note: "Pit F, empty, cooling."),
      Pit.new(pit: "G", kai: "fish", note: "Pit G, fish, not for the school."),
      Pit.new(pit: "H", kai: "dessert", note: "Pit H, steamed pudding, after the school basket.")
    ].freeze

    QUERY = "Which pit is the school hāngī basket with chicken and kumara?"

    INSTRUCTIONS = <<~TEXT.strip
      You are the pit clerk at a Rotorua hāngī.
      Answer in one short sentence from the winning pit only.
      Name pit D and 11:40.
    TEXT

    Result = Struct.new(:index, :pit, :kai, :count, :brief, :roles, :input_tokens, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, PITS.map(&:note), **Multivitamin::Models.rerank, top_n: 3)
      winner = ranked.results.first
      pit = PITS.fetch(winner.index)

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      message = chat.ask(pit.note)

      Result.new(
        index: winner.index,
        pit: pit.pit,
        kai: pit.kai,
        count: ranked.results.length,
        brief: message.content,
        roles: chat.messages.map(&:role),
        input_tokens: ranked.tokens.input
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
  Multivitamin::Cassettes.play(__dir__, "hangi_desk") do
    result = RotoruaHangiPit::HangiDesk.conduct
  end

  puts "pit=#{result.pit} kai=#{result.kai} count=#{result.count}"
  puts result.brief
end
