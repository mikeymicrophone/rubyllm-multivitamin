# frozen_string_literal: true

# Embeddings · 06 · Dublin Abbey prompt copy
#
# Teaches:
# - The same entrance cue embedded twice is closer to itself than to a
#   different rain-machine note.
# - One batch holds the note, its copy, and the rain.

require_relative "../../../support/runtime"
require_relative "../../../support/vectors"

module DublinPromptCopy
  # The prompt at the Abbey files Maurya's Act II entrance twice by
  # accident, then files the afternoon rain-machine.
  class PromptCopy
    ENTRANCE = <<~TEXT.strip
      Prompt copy, Act II entrance of Maurya, 19:20.
      Follow-spot is 9 seconds, 31.5 degrees, three-meter throw, no follow-on.
      House light on, rain moderate from the west fly. Prompt: Aoife.
    TEXT

    RAIN = <<~TEXT.strip
      Afternoon rain-machine at the Abbey, 15:40.
      Tank 2.4 bar on the west fly. Spray 6 mm at 8 seconds. No entrance until
      the spray drops below 4 mm.
    TEXT

    NOTES = [ENTRANCE, ENTRANCE, RAIN].freeze

    Result = Struct.new(
      :self_score,
      :current_score,
      :model_id,
      :input_tokens,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      embedding = RubyLLM.embed(NOTES, **Multivitamin::Models.embed(provider: :openai))
      first, copy, current = embedding.vectors

      Result.new(
        self_score: cosine(first, copy),
        current_score: cosine(first, current),
        model_id: embedding.model,
        input_tokens: embedding.tokens.input,
        cost: embedding.cost.total
      )
    end

    def self.cosine(left, right) = Multivitamin::Vectors.cosine(left, right)

    def self.configure = Multivitamin::Runtime.configure(provider: :openai)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "prompt_copy") do
    DublinPromptCopy::PromptCopy.conduct
  end

  puts "copy #{result.self_score.round(6)} current #{result.current_score.round(4)}"
end
