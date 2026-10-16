# frozen_string_literal: true

# Tokenization · 06 · Granada Alhambra plaster
#
# Teaches:
# - with_schema includes a nested Schematist schema in the token count.
# - A fluent chat pipeline uses then to compare bare and structured request counts.
# - Neither count stages a question or generates a JSON answer.

require_relative "../../../support/runtime"

module GranadaAlhambraPlaster
  class PlasterCard < Schematist::Schema
    title "alhambra_plaster_card"
    string :courtyard, description: "Courtyard named on the conservation slip"
    object :repair do
      string :panel, description: "Panel reference on the slip"
      number :area_cm2, description: "Measured plaster loss in square centimetres"
      boolean :hold, description: "Whether the panel must remain roped off"
    end
  end

  QUESTION = "Court of the Lions: Inés logs panel ALH-6, plaster loss 24 cm2, rope remains. Prepare the repair card."
  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      .with_instructions("Copy the Alhambra conservation slip exactly.")
      .then do |chat|
        bare = chat.count_tokens(QUESTION)
        structured = chat.with_schema(PlasterCard).count_tokens(QUESTION)
        { bare: bare, structured: structured, roles: chat.messages.map(&:role) }
      end
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "plaster_card") do
    GranadaAlhambraPlaster.conduct
  end

  puts "bare=#{result.fetch(:bare)} structured=#{result.fetch(:structured)}"
end
