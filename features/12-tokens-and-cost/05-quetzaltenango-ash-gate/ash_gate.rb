# frozen_string_literal: true

# Tokens and cost · 05 · Quetzaltenango ash-gate cap
#
# Teaches:
# - with_max_output_tokens is a token budget on the reply.
# - A tight cap can finish with max_tokens? true.
# - tokens.output still reports the tokens that were used under that cap.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module QuetzaltenangoAshGate
  # The ash clerk in Quetzaltenango tries to post a Santa María gate
  # note under a 64-token budget. The desk reads finish_reason and the
  # output count, not only the spoken words.
  class AshGate
    INSTRUCTIONS = <<~TEXT.strip
      You are the ash clerk at the municipal gate in Quetzaltenango.
      Use only the ash table in this chat.
      Name fall 3.1 mm and the bus Xela.
      Do not invent a clearing time.
    TEXT

    TABLE_QUESTION = <<~TEXT.strip
      Santa María ash table copied at Quetzaltenango, Friday 16 October 2026.
      Volcano notes: https://www.insivumeh.gob.gt/
      City page: https://www.xela.gob.gt/
      Ash fall 3.1 mm at 11:20, drifting southeast past the Minerva terminal.
      Clearing before the afternoon run 14:05.
      The intercity bus Xela needs a clear road to work the Almolonga grade.
      Write two sentences the desk can post: the fall figure, the clearing clock, and that Xela waits for 14:05.
    TEXT

    OUTPUT_BUDGET = 64

    Result = Struct.new(
      :content,
      :thinking,
      :finish,
      :max_tokens,
      :output_tokens,
      :thinking_tokens,
      :input_tokens,
      :output_cap,
      :raw_status,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_max_output_tokens(OUTPUT_BUDGET)
      note = chat.ask(TABLE_QUESTION)

      Result.new(
        content: note.content,
        thinking: note.thinking&.text,
        finish: note.finish_reason,
        max_tokens: note.max_tokens?,
        output_tokens: note.tokens.output,
        thinking_tokens: note.tokens.thinking,
        input_tokens: note.tokens.input,
        output_cap: chat.max_output_tokens,
        raw_status: note.raw.status
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "ash_gate") do
    result = QuetzaltenangoAshGate::AshGate.conduct
  end

  puts "finish=#{result.finish} max_tokens=#{result.max_tokens} out=#{result.output_tokens} " \
       "thinking=#{result.thinking_tokens} cap=#{result.output_cap}"
  puts result.content.inspect
end
