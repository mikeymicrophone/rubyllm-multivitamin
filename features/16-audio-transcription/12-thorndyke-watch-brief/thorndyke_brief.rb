# frozen_string_literal: true

# Audio transcription · 12 · Thorndyke watch brief
#
# Teaches:
# - A transcript is ordinary text for the next chat.ask.
# - The chat never sees the MP3. It sees tape.text.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ThorndykeWatchBrief
  # The float at Thorndyke Bay, on Hood Canal, records Alden's kelp-ledge
  # clearance. The clerk transcribes the tape, then asks the tide clerk to
  # write the posted brief from that text.
  class KelpBrief
    RECORDING = File.expand_path("thorndyke-kelp.mp3", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at Thorndyke Bay on Hood Canal.
      Write one short sentence for the incoming watch.
      Use only the tape. Name Alden. Do not invent a tide height.
    TEXT

    Result = Struct.new(:tape_text, :brief, :roles, :tape_model, keyword_init: true)

    def self.conduct
      configure
      tape = RubyLLM.transcribe(RECORDING, **Multivitamin::Models.transcribe)
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask("Write the posted brief from this tape:\n#{tape.text}")

      Result.new(
        tape_text: tape.text,
        brief: brief.content,
        roles: chat.messages.map(&:role),
        tape_model: tape.model
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
  Multivitamin::Cassettes.play(__dir__, "thorndyke_brief") do
    result = ThorndykeWatchBrief::KelpBrief.conduct
  end

  puts result.tape_text
  puts
  puts result.brief
end
