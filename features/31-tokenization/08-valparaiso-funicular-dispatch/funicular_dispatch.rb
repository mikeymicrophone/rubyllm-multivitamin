# frozen_string_literal: true

# Tokenization · 08 · Valparaíso funicular dispatch
#
# Teaches:
# - Tokenize extracts only a staged bulletin's plain text, excluding the chat's instructions.
# - A refinement cleans posted lines without changing String globally.
# - lazy and numbered block parameters build the dispatch bulletin.

require_relative "../../../support/runtime"

module ValparaisoFunicularDispatch
  module PostedLines
    refine String do
      def dispatch_lines = lines.map(&:strip).reject(&:empty?)
    end
  end
  using PostedLines

  BOARD = <<~TEXT
    Ascensor El Peral: Camila opens gate VAP-2 at 09:10.

    Ascensor Reina Victoria: Tomás holds cabin VAP-7 for inspection.
  TEXT
  module_function

  def conduct
    context = RubyLLM.context { |config| Multivitamin::Runtime.apply(config, provider: :xai) }
    bulletin = BOARD.dispatch_lines.lazy.map { "Dispatch: #{_1}" }.to_a.join("\n")
    chat = context.chat(model: Multivitamin::Models::XAI_TOKENIZER, provider: :xai)
      .with_instructions("You are the Valparaíso funicular dispatcher. Name only the cabin that must wait.")
    chat.ask_later(bulletin)
    tokens = context.tokenize(chat.messages.last.content,
      model: Multivitamin::Models::XAI_TOKENIZER, provider: :xai)
    { plain: tokens.count, model: tokens.model, complete: chat.complete?,
      roles: chat.messages.map(&:role), bulletin: bulletin }
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "funicular_dispatch") do
    ValparaisoFunicularDispatch.conduct
  end

  puts "plain bulletin=#{result.fetch(:plain)} on #{result.fetch(:model)}; chat awaits generation=#{!result.fetch(:complete)}"
end
