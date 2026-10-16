# frozen_string_literal: true

# Tools · 02 · Fes tanner vat card
#
# Teaches:
# - A required keyword on execute becomes a required string parameter
#   when the tool does not declare parameter.
# - call returns { error: } for a missing or unknown keyword. execute
#   does not run, and nothing is raised.
# - Stored procs observe the completed tool call and its result.

require_relative "../../../support/runtime"

module FesTannerVat
  # The tanner names a vat. The tool's schema is inferred from execute.
  class VatCard < RubyLLM::Tool
    description "Looks up one dye vat in the Chouara tanneries at Fes"

    def self.tool_name
      "vat_card"
    end

    VATS = {
      "chouara" => "Chouara vat: spare saffron dye, wrapped, marked FEZ-4.",
      "guissa" => "Bab Guissa vat: oak-bark liquor for a 30-day soak.",
      "recif" => "Recif vat: two lime pits, one cracked."
    }.freeze

    def execute(vat:)
      VATS.fetch(vat.to_s.downcase) { "No vat named #{vat} in the Chouara tanneries." }
    end
  end

  class VatLookup
    INSTRUCTIONS = <<~TEXT.strip
      You are the vat clerk at the Chouara tanneries in Fes.
      Call vat_card with the vat named in the question: chouara, guissa, or recif.
      Answer in one sentence and include the mark the tool returns.
    TEXT

    VAT_QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, morning soak at Chouara, Fes.
      Medina notes: https://whc.unesco.org/en/list/170/
      The soaking crew wants the chouara vat opened before the saffron is mixed.
      What is in that vat?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :arguments, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(VatCard)
      chat.with_tool_options(choice: VatCard)

      arguments = nil
      tool_content = nil
      note_arguments = proc { |call| arguments = call.arguments }
      note_contents = proc { |contents| tool_content = contents }
      chat.before_tool_call(&note_arguments)
      chat.after_tool_result(&note_contents)
      answer = chat.ask(VAT_QUESTION)

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_content,
        arguments: arguments
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "vat_card") do
    FesTannerVat::VatLookup.conduct
  end

  puts result.answer
end
