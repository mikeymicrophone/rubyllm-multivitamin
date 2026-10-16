# frozen_string_literal: true

# Tokenization · 03 · Iguazú walkway brief
#
# Teaches:
# - RubyLLM.count_tokens counts a complete text request on OpenAI Responses.
# - method(:format_notice) passed with & builds a bulletin from named closure rows.
# - The returned Integer is an input estimate; no assistant turn is generated.

require_relative "../../../support/runtime"

module IguazuWalkwayBrief
  NOTICES = [
    ["Garganta del Diablo", "Marta checks the railing at 08:10"],
    ["Circuito Superior", "Diego holds group IGU-12 until the board clears"]
  ].freeze

  module_function

  def format_notice(notice)
    walkway, instruction = notice
    "#{walkway}: #{instruction}."
  end

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    bulletin = NOTICES.map(&method(:format_notice)).join("\n")
    question = "Iguazú dispatch board:\n#{bulletin}\nWhich group must wait?"
    count = RubyLLM.count_tokens(question, model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
    { bulletin: bulletin, count: count }
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "walkway_brief") do
    IguazuWalkwayBrief.conduct
  end

  puts result.fetch(:bulletin)
  puts "input estimate=#{result.fetch(:count)}"
end
