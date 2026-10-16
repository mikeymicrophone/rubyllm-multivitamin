# frozen_string_literal: true

# Embeddings · 05 · Helsinki reserve slip
#
# Teaches:
# - model: selects the embedding slug. The request names it.
# - task_type: and title: are accepted by RubyLLM.embed.
# - OpenAI's embeddings encoder omits both. The query and document
#   requests differ only in input_type if a provider sends one; this
#   cassette does not.

require_relative "../../../support/runtime"
require_relative "../../../support/vectors"

module HelsinkiReserveSlip
  # The reserve desk at Oodi embeds the same hold remark once as a
  # retrieval query and once as a document. OpenAI ignores those labels.
  class ReserveSlip
    REMARK = <<~TEXT.strip
      Helsinki City Library reserve slip B4, Wednesday 14 October 2026.
      The score Sibelius Kullervo takes desk B4 at 14:10 after the school
      copy of Kalevala is collected. Do not stack the oversize atlas on B4.
      Hold traffic on the desk is 1.2 requests from the south stack.
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
        title: "Helsinki reserve slip B4"
      )
      document = RubyLLM.embed(
        REMARK,
        **args,
        task_type: "RETRIEVAL_DOCUMENT",
        title: "Helsinki reserve slip B4"
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

    def self.cosine(left, right) = Multivitamin::Vectors.cosine(left, right)

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "reserve_slip") do
    HelsinkiReserveSlip::ReserveSlip.conduct
  end

  puts "query versus document #{result.score.round(6)}"
end
