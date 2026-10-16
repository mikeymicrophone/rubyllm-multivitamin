# frozen_string_literal: true

# Tokenization · 01 · Kyoto torii inscription
#
# Teaches:
# - Cohere tokenize returns ids, count, model, and the unmodified raw response.
# - A customized immutable Data record checks an inscription against a label allowance.
# - Plain-text IDs exclude request formatting and billed usage.

require_relative "../../../support/runtime"

module KyotoToriiInscription
  Inscription = Data.define(:text, :tokenization, :allowance) do
    def fits? = tokenization.count <= allowance
    def remaining = allowance - tokenization.count
  end

  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :cohere)
    inscription = "伏見稲荷大社 — Akiko checks torii KYT-17 before 07:30."
    tokenization = RubyLLM.tokenize(
      inscription, model: Multivitamin::Models::COHERE_TOKENIZER, provider: :cohere
    )
    Inscription.new(text: inscription, tokenization: tokenization, allowance: 40)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "torii_inscription") do
    KyotoToriiInscription.conduct
  end

  puts "#{result.text}
#{result.tokenization.count} tokens; #{result.remaining} left; fits=#{result.fits?}"
end
