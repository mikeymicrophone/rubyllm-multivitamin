# frozen_string_literal: true

# Text to speech · 13 · Beckett Point radio hail capstone
#
# Teaches:
# - chat.ask writes a radio card, then speak, then save.
# - The saved path is the spoken answer.
# - Roles, the speech model, and the file bytes sit on one card.

require "logger"
require "ruby_llm"
require "tmpdir"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BeckettPointRadioHail
  # The radio clerk at Beckett Point writes a one-sentence card for the
  # packet Alden, speaks it, and files the clip next to the card.
  class BeckettRadio
    INSTRUCTIONS = <<~TEXT.strip
      You are the radio clerk at Beckett Point on Discovery Bay.
      Answer in one short sentence of at most ten words.
      Name Beckett Point and the packet Alden.
      Do not invent a tide height.
    TEXT

    QUESTION = "Write the radio card hail for Alden inbound at Beckett Point."

    Result = Struct.new(
      :answer,
      :speech_model,
      :saved_path,
      :file_bytes,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      answer = chat.ask(QUESTION)

      speech = RubyLLM.speak(answer.content, **Multivitamin::Models.speech)
      path = File.join(Dir.mktmpdir("beckett-point-"), "radio_card.mp3")
      speech.save(path)

      Result.new(
        answer: answer.content,
        speech_model: speech.model,
        saved_path: path,
        file_bytes: File.binread(path),
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "beckett_radio") do
    result = BeckettPointRadioHail::BeckettRadio.conduct
  end

  puts result.answer
  puts result.saved_path
end
