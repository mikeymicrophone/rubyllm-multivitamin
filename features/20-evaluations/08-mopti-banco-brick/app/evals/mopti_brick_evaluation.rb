# frozen_string_literal: true

# Discovered by ruby_llm:eval as app/evals/*_evaluation.rb.
# Configure RubyLLM before loading this file.

class MoptiBrickEvaluation < RubyLLM::Evaluation
  dataset File.expand_path("mopti_brick_evaluation.yml", __dir__)
  evaluator Multivitamin::Models::OPENAI_CHAT, provider: :openai

  INSTRUCTIONS = <<~TEXT.strip
    You are the brick clerk on the west wall at the Great Mosque yard in Mopti.
    Answer in one short sentence from the card only.
    Name 64 bricks and Aissata.
  TEXT

  def perform(input)
    card = <<~TEXT.strip
      Mopti west-wall card, Friday 16 October 2026.
      64 banco bricks. Aissata tamps the next course.
      #{input}
    TEXT
    chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    Multivitamin::Models.quiet_thinking(chat, provider: :openai)
    chat.with_instructions(INSTRUCTIONS)
    chat.with_temperature(0.2)
    chat.ask(card)
  end
end
