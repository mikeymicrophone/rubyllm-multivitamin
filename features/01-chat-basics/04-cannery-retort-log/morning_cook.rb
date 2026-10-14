# frozen_string_literal: true

# Chat basics · 04 · Cannery retort log for the morning cook
#
# Teaches:
# - Three asks on one chat: the cook, a correction, then a recap.
# - The recap can use both earlier turns because the chat keeps them.
# - Later requests carry the earlier assistant turn, including its reasoning
#   details when OpenRouter sent them.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesRetortLog
  # The cannery clerk logs retort No. 2, takes a correction from the
  # retort man, and writes the office recap from both turns.
  class MorningCook
    INSTRUCTIONS = <<~TEXT.strip
      You are the retort clerk at the Anacortes cannery.
      The tender ties at the Port of Anacortes marina, https://www.portofanacortes.com/.
      Keep each reply to two short sentences.
      Use only the cook card and the corrections in this chat.
      Do not invent temperatures, baskets, or times.
      When a later turn corrects a figure, the recap uses the corrected figure.
    TEXT

    COOK_QUESTION = <<~TEXT.strip
      Morning cook card for Wednesday 14 October 2026, retort No. 2.
      Product: sockeye halves.
      Basket 3.
      Posted temperature 240 F.
      Cook 75 minutes.
      Come-up started 05:10.
      Write the log line for the cannery office.
    TEXT

    CORRECTION_QUESTION = <<~TEXT.strip
      The retort man, Calder, just came down from the gallery.
      The mercury was reading high.
      True temperature for this cook is 242 F, not 240 F.
      Basket 3, 75 minutes, and the 05:10 come-up stay as posted.
      Correct the log line.
    TEXT

    RECAP_QUESTION = "Recap the morning cook for the office. Use the corrected temperature, the basket, and the minutes."

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

      chat = RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      log_line = chat.ask(COOK_QUESTION)
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
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "morning_cook") do
    result = AnacortesRetortLog::MorningCook.conduct
  end

  puts result.log_line
  puts
  puts result.correction
  puts
  puts result.recap
end
