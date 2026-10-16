# frozen_string_literal: true

# Batches · 06 · Berat wood-lattice mix raises
#
# Teaches:
# - A batch takes chats or embedding requests, not both.
# - Mixing them raises ArgumentError before any HTTP call.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BeratWoodLattice
  class LatticeMix
    LATTICE = "Berat wood-lattice loft, 13 screens on the east rack, clerk Liri."

    Result = Struct.new(:error_class, :message, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions("Name 13 screens and Liri.")
      chat.ask_later("Berat lattice card. How many screens on the east rack?")
      embedding = RubyLLM.embed_later(
        LATTICE,
        model: Multivitamin::Models::OPENAI_EMBEDDING,
        provider: :openai
      )
      RubyLLM.batch([chat, embedding])
    rescue ArgumentError => error
      Result.new(error_class: error.class.name, message: error.message)
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

    def self.open_chat(model: nil)
      kwargs = Multivitamin::Models.chat(provider: :openai)
      kwargs = kwargs.merge(model: model) if model
      chat = RubyLLM.chat(**kwargs)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

  end
end

if $PROGRAM_NAME == __FILE__
  result = BeratWoodLattice::LatticeMix.conduct
  puts "#{result.error_class}: #{result.message}"
end
