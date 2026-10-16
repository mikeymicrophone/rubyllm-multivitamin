# frozen_string_literal: true

# Embeddings · 07 · Bishkek precinct tally cards
#
# Teaches:
# - An empty string still embeds on OpenAI. tokens.input is 0 and cost is 0.
# - An empty array raises RubyLLM::BadRequestError before a vector exists.

require_relative "../../../support/runtime"

module BishkekTallyCards
  # The precinct clerk in Sverdlov tries to file a blank tally card, then
  # an empty stack of cards. The blank card is a vector. The empty stack
  # is a 400.
  class TallyCards
    Result = Struct.new(
      :blank_length,
      :blank_tokens,
      :blank_cost,
      :blank_all_zero,
      :stack_error,
      :stack_message,
      keyword_init: true
    )

    def self.conduct
      configure
      args = Multivitamin::Models.embed(provider: :openai)
      blank = RubyLLM.embed("", **args)

      stack_error = nil
      stack_message = nil
      begin
        RubyLLM.embed([], **args)
      rescue RubyLLM::BadRequestError => error
        stack_error = error.class.name
        stack_message = error.message
      end

      Result.new(
        blank_length: blank.vectors.length,
        blank_tokens: blank.tokens.input,
        blank_cost: blank.cost.total,
        blank_all_zero: blank.vectors.all? { |value| value == 0.0 },
        stack_error: stack_error,
        stack_message: stack_message
      )
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "tally_cards") do
    BishkekTallyCards::TallyCards.conduct
  end

  puts "blank #{result.blank_length} tokens #{result.blank_tokens}"
  puts result.stack_message
end
