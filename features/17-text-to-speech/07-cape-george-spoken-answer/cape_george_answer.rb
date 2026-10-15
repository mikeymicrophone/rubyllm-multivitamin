# frozen_string_literal: true

# Text to speech · 07 · Cape George spoken chat answer
#
# Teaches:
# - chat.ask writes a hail, then RubyLLM.speak reads that answer.
# - The speech request body is the assistant content, not the question.
# - Two HTTP calls share one cassette: chat, then speech.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeGeorgeSpokenAnswer
  # The watch at Cape George asks the clerk for a one-sentence inbound
  # hail, then speaks that answer over Discovery Bay.
  class CapeGeorgeAnswer
    INSTRUCTIONS = <<~TEXT.strip
      You are the watch at Cape George on Discovery Bay.
      Answer in one short sentence of at most ten words.
      Name Cape George and the packet Alden.
      Do not invent a tide height.
    TEXT

    QUESTION = "Write the inbound hail for the packet Alden off Cape George."

    Result = Struct.new(:answer, :speech_model, :roles, :spoken_bytes, keyword_init: true)

    def self.conduct
      configure
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      answer = chat.ask(QUESTION)
      speech = RubyLLM.speak(answer.content, **Multivitamin::Models.speech)

      Result.new(
        answer: answer.content,
        speech_model: speech.model,
        roles: chat.messages.map(&:role),
        spoken_bytes: speech.to_blob.bytesize
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "cape_george_answer") do
    result = CapeGeorgeSpokenAnswer::CapeGeorgeAnswer.conduct
  end

  puts result.answer
  puts result.speech_model
end
