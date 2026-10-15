# frozen_string_literal: true

# Agents · 03 · Cape Disappointment blast card
#
# Teaches:
# - schema do ... end on an Agent is the Schematist DSL.
# - ask still returns a Message. parsed is the Hash with string keys.
# - content stays the JSON text.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentBlastCard
  class HornClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2

    instructions <<~TEXT.strip
      You are the foghorn clerk at Cape Disappointment.
      Fill the blast card from the posted horn card in the question.
      Copy the blast seconds and the compressor figure exactly.
      Do not invent a pattern.
    TEXT

    schema do
      string :station, description: "Light station name, copied from the horn card"
      integer :blast_seconds, description: "Length of each blast in seconds"
      integer :gap_seconds, description: "Silence between blasts in seconds"
      integer :compressor_psi, description: "Posted compressor pressure"
    end
  end

  class BlastCard
    HORN_CARD = <<~TEXT.strip
      Cape Disappointment horn card for Wednesday 15 October 2026.
      Station notes: https://www.nps.gov/lewi/learn/historyculture/cape-disappointment.htm
      Pattern: 3-second blast, 27-second gap, repeated.
      Compressor: 90 psi.
      Fill the blast card for the incoming watch.
    TEXT

    Result = Struct.new(:content, :parsed, :roles, :schema_title, :cost, keyword_init: true)

    def self.conduct
      configure
      agent = open_agent
      answer = agent.ask(HORN_CARD)

      Result.new(
        content: answer.content,
        parsed: answer.parsed,
        roles: agent.messages.map(&:role),
        schema_title: agent.schema&.[]("name") || agent.schema&.[](:name),
        cost: answer.cost.total
      )
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = HornClerk.new(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(agent, provider: :openai)
      agent
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
  Multivitamin::Cassettes.play(__dir__, "blast_card") do
    result = CapeDisappointmentBlastCard::BlastCard.conduct
  end

  puts result.content
  puts JSON.generate(result.parsed)
end
