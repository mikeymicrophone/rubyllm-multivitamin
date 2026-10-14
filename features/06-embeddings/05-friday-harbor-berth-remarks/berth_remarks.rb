# frozen_string_literal: true

# Embeddings · 05 · Friday Harbor berth remarks
#
# Teaches:
# - model: selects the embedding slug. The request names it.
# - task_type: and title: are accepted by RubyLLM.embed.
# - OpenAI's embeddings encoder omits both. The query and document
#   requests differ only in input_type if a provider sends one; this
#   cassette does not.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborBerthRemarks
  # The berth desk at Friday Harbor embeds the same slip remark once as a
  # retrieval query and once as a document. OpenAI ignores those labels.
  class BerthRemarks
    REMARK = <<~TEXT.strip
      Friday Harbor slip B4, Wednesday 14 October 2026.
      The packet San Juan Islander takes B4 at 14:10 after the whale-watch
      boat Orca Song vacates. Do not raft the tender Alden outside B4.
      Current on the float is flooding 1.2 kn from the south.
    TEXT

    Result = Struct.new(
      :query_vector,
      :document_vector,
      :score,
      :model_id,
      :query_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      args = Multivitamin::Models.embed(provider: :openai)
      query = RubyLLM.embed(
        REMARK,
        **args,
        task_type: "RETRIEVAL_QUERY",
        title: "Friday Harbor slip B4"
      )
      document = RubyLLM.embed(
        REMARK,
        **args,
        task_type: "RETRIEVAL_DOCUMENT",
        title: "Friday Harbor slip B4"
      )

      Result.new(
        query_vector: query.vectors,
        document_vector: document.vectors,
        score: cosine(query.vectors, document.vectors),
        model_id: query.model,
        query_tokens: query.tokens.input,
        cost: query.cost.total + document.cost.total
      )
    end

    def self.cosine(left, right)
      dot = 0.0
      na = 0.0
      nb = 0.0
      left.each_index do |index|
        dot += left[index] * right[index]
        na += left[index] * left[index]
        nb += right[index] * right[index]
      end
      dot / (Math.sqrt(na) * Math.sqrt(nb))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "berth_remarks") do
    result = FridayHarborBerthRemarks::BerthRemarks.conduct
  end

  puts "query versus document #{result.score.round(6)}"
end
