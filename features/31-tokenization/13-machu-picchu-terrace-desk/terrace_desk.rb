# frozen_string_literal: true

# Tokenization · 13 · Machu Picchu terrace desk
#
# Teaches:
# - An explicit admission loop counts each candidate against the growing conversation.
# - A separate output reserve defines the input ceiling; estimates never predict output length.
# - Pattern matching destructures dispatch cards; break prevents staging an over-budget turn.

require_relative "../../../support/runtime"

module MachuPicchuTerraceDesk
  Dispatch = Data.define(:crew, :question)
  Admission = Data.define(:crew, :estimate, :accepted)

  class TerraceDesk
    CONTEXT_ALLOWANCE = 400
    OUTPUT_RESERVE = 100
    DISPATCHES = [
      Dispatch.new(crew: "Quispe", question: "Machu Picchu board: Quispe checks drain MP-4 at 08:20. Which drain is assigned?"),
      Dispatch.new(crew: "Huamán", question: "Huamán waits below terrace MP-7 until Quispe clears MP-4 at 08:20. Who must wait?"),
      Dispatch.new(crew: "Sisa", question: "Sisa's backlog: " + (1..12).map { |drain| "terrace MP-#{drain} needs a drainage inspection" }.join("; ") + ". List every inspection.")
    ].freeze

    def self.conduct = new.conduct

    def conduct
      Multivitamin::Runtime.configure(provider: :openai)
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
        .with_instructions("You are the Machu Picchu terrace clerk. Answer only from the crew board in one short sentence.")
        .with_max_output_tokens(OUTPUT_RESERVE)
      admissions = []
      briefs = []
      DISPATCHES.each do |dispatch|
        case dispatch
        in Dispatch[crew:, question:]
          estimate = chat.count_tokens(question)
          accepted = estimate <= CONTEXT_ALLOWANCE - OUTPUT_RESERVE
          admissions << Admission.new(crew: crew, estimate: estimate, accepted: accepted)
          break unless accepted

          chat.ask_later(question)
          briefs << chat.complete.content
        end
      end
      { admissions: admissions, briefs: briefs, roles: chat.messages.map(&:role),
        input_ceiling: CONTEXT_ALLOWANCE - OUTPUT_RESERVE, usage_entries: chat.usage_entries.length }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "terrace_desk") do
    MachuPicchuTerraceDesk::TerraceDesk.conduct
  end

  result.fetch(:admissions).each { |admission| puts "#{admission.crew}: #{admission.estimate}, admitted=#{admission.accepted}" }
  puts result.fetch(:briefs)
end
