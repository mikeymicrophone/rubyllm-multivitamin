# frozen_string_literal: true

# Tokenization · 02 · Samarkand Registan label
#
# Teaches:
# - xAI returns token_id entries; ids retain their text order, including repetitions.
# - zip joins IDs to raw token strings; filter_map selects recurring mosaic words.
# - A context owns its tokenizer credentials without changing global configuration.

require_relative "../../../support/runtime"

module SamarkandRegistanLabel
  module_function

  def conduct
    context = RubyLLM.context { |config| Multivitamin::Runtime.apply(config, provider: :xai) }
    tokenization = context.tokenize(
      "Registan tile, tile, tile: Dilshod checks turquoise panel SAM-8.",
      model: Multivitamin::Models::XAI_TOKENIZER, provider: :xai
    )
    fragments = tokenization.raw.fetch("token_ids").map { _1.fetch("string_token") }
    ordered = tokenization.ids.zip(fragments)
    repeated = ordered.filter_map { |id, fragment| id if fragment.strip == "tile" }
    { tokenization: tokenization, ordered: ordered, repeated: repeated }
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "registan_label") do
    SamarkandRegistanLabel.conduct
  end

  result.fetch(:ordered).each { |id, fragment| puts "#{id}: #{fragment.inspect}" }
end
