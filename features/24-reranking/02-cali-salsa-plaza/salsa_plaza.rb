# frozen_string_literal: true

# Reranking · 02 · Cali salsa plaza
#
# Teaches:
# - top_n: shrinks the response, not the work.
# - Eight flyers still go on the wire. Five come back.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CaliSalsaPlaza
  # The plaza clerk in Cali has eight salsa flyers and wants the five
  # that match tonight's sonoridad rehearsal. Voyage scores all eight
  # and returns five.
  class SalsaPlaza
    QUERY = "Which flyers are for tonight's sonoridad rehearsal on Calle Quinta?"

    FLYERS = [
      "Sunday rumba at Parque del Perro, noon, outdoor.",
      "Sonoridad rehearsal tonight on Calle Quinta, 19:30, closed shoes.",
      "Cali salsa congress next July, ticket booth at Plaza Caicedo.",
      "Calle Quinta sonoridad call: second set at 20:15, bring the clave.",
      "Salsa aerobics at Unicentro, Tuesday mornings.",
      "Tonight's sonoridad on Calle Quinta needs two extra singers.",
      "Vallenato night in Granada, not salsa.",
      "Calle Quinta sonoridad: mute the brass after 21:00."
    ].freeze

    Result = Struct.new(:count, :documents, :model, keyword_init: true)

    def self.conduct
      configure

      ranked = RubyLLM.rerank(QUERY, FLYERS, **Multivitamin::Models.rerank, top_n: 5)

      Result.new(
        count: ranked.results.length,
        documents: ranked.results.map(&:document),
        model: ranked.model
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "salsa_plaza") do
    result = CaliSalsaPlaza::SalsaPlaza.conduct
  end

  puts "count=#{result.count}"
  puts result.documents
end
