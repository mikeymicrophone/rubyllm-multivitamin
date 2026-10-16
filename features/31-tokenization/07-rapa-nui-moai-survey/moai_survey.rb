# frozen_string_literal: true

# Tokenization · 07 · Rapa Nui moai survey
#
# Teaches:
# - ask_later stages a new PDF before count_tokens; counting takes no with: keyword.
# - An immutable field sheet carries its local path and the survey question.
# - The count includes inline PDF bytes; the chat stays incomplete without generating.

require_relative "../../../support/runtime"

module RapaNuiMoaiSurvey
  FieldSheet = Data.define(:path, :question)
  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    sheet = FieldSheet.new(
      path: File.expand_path("fixtures/ahu-tongariki.pdf", __dir__),
      question: "From the Ahu Tongariki field sheet, which moai does Hina keep under observation?"
    )
    chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      .with_instructions("Read only the attached Rapa Nui conservation field sheet.")
    chat.ask_later(sheet.question, with: sheet.path)
    estimate = chat.count_tokens
    { estimate: estimate, roles: chat.messages.map(&:role), complete: chat.complete?,
      attachments: chat.messages.last.attachments.map(&:filename) }
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "moai_survey") do
    RapaNuiMoaiSurvey.conduct
  end

  puts "input estimate=#{result.fetch(:estimate)}; awaiting generation=#{!result.fetch(:complete)}"
end
