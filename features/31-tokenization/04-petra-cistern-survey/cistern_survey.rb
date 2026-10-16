# frozen_string_literal: true

# Tokenization · 04 · Petra cistern survey
#
# Teaches:
# - An instance owns a context chat with instructions and seeded survey history.
# - chat.count_tokens(question) includes a temporary user turn without appending it.
# - case/in destructures a survey record into a follow-up question.

require_relative "../../../support/runtime"

module PetraCisternSurvey
  Survey = Data.define(:cistern, :surveyor, :depth_cm)

  class SurveyDesk
    def initialize
      context = RubyLLM.context { |config| Multivitamin::Runtime.apply(config, provider: :openai) }
      @chat = context.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
        .with_instructions("You are Petra's cistern clerk. Keep the Siq survey separate from the Treasury steps.")
      @chat.add_message(role: :user, content: "Nadia measured Siq cistern PTR-4 at 62 cm.")
      @chat.add_message(role: :assistant, content: "PTR-4 is logged at 62 cm for Nadia.")
    end

    def self.conduct = new.conduct

    def conduct
      survey = Survey.new(cistern: "PTR-4", surveyor: "Nadia", depth_cm: 62)
      question = case survey
      in Survey[cistern:, surveyor:, depth_cm:]
        "Does #{surveyor}'s #{cistern} reading of #{depth_cm} cm belong to the Siq?"
      end
      before = @chat.messages.dup
      estimate = @chat.count_tokens(question)
      { estimate: estimate, before: before, after: @chat.messages.dup, question: question }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "cistern_survey") do
    PetraCisternSurvey::SurveyDesk.conduct
  end

  puts "#{result.fetch(:question)}
input estimate=#{result.fetch(:estimate)}"
end
