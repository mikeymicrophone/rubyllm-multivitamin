# frozen_string_literal: true

# Chat basics · 04 · Lagos ankara bale log for the morning receiving
#
# Teaches:
# - Three asks on one chat: the receiving, a correction, then a recap.
# - The recap can use both earlier turns because the chat keeps them.
# - Later requests carry the earlier assistant turn, including its reasoning
#   details when OpenRouter sent them.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LagosAnkaraBale
  # The wholesale clerk logs bale No. 2, takes a correction from the
  # warehouse, and writes the office recap from both turns.
  class MorningBale
    INSTRUCTIONS = <<~TEXT.strip
      You are the receiving clerk at the Balogun Market wholesale house in Lagos.
      The bales land at the Apapa warehouse, https://www.npa.gov.ng/.
      Keep each reply to two short sentences.
      Use only the receiving card and the corrections in this chat.
      Do not invent yardages, bales, or times.
      When a later turn corrects a figure, the recap uses the corrected figure.
    TEXT

    BALE_QUESTION = <<~TEXT.strip
      Morning receiving card for Wednesday 14 October 2026, bale No. 2.
      Product: ankara wax print.
      Bale 3.
      Posted length 240 yards.
      Count 75 pieces.
      Unload started 05:10.
      Write the log line for the wholesale office.
    TEXT

    CORRECTION_QUESTION = <<~TEXT.strip
      The warehouse lead, Kemi, just came down from the mezzanine.
      The tape was reading short.
      True length for this bale is 242 yards, not 240 yards.
      Bale 3, 75 pieces, and the 05:10 unload stay as posted.
      Correct the log line.
    TEXT

    RECAP_QUESTION = "Recap the morning receiving for the office. Use the corrected length, the bale, and the piece count."

    Result = Struct.new(
      :log_line,
      :correction,
      :recap,
      :roles,
      :log_input_tokens,
      :recap_input_tokens,
      :log_finish,
      :recap_finish,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      log_line = chat.ask(BALE_QUESTION)
      correction = chat.ask(CORRECTION_QUESTION)
      recap = chat.ask(RECAP_QUESTION)

      Result.new(
        log_line: log_line.content,
        correction: correction.content,
        recap: recap.content,
        roles: chat.messages.map(&:role),
        log_input_tokens: log_line.tokens.input,
        recap_input_tokens: recap.tokens.input,
        log_finish: log_line.finish_reason,
        recap_finish: recap.finish_reason
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "morning_bale") do
    result = LagosAnkaraBale::MorningBale.conduct
  end

  puts result.log_line
  puts
  puts result.correction
  puts
  puts result.recap
end
