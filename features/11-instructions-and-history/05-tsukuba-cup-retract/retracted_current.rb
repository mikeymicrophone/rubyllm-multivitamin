# frozen_string_literal: true

# Instructions and history · 05 · Tsukuba Faraday-cup retraction
#
# Teaches:
# - chat.messages is the transcript the next request will send.
# - Assigning messages drops a retracted user and assistant turn.
# - The next request body no longer carries the bad current.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TsukubaCupRetract
  # The beam clerk at KEK Tsukuba logs a fouled Faraday cup of 14 nA
  # under line DH, then retracts that pair from the transcript before
  # posting the corrected 22 nA current.
  class RetractedCurrent
    INSTRUCTIONS = <<~TEXT.strip
      You are the beam clerk working the Faraday cup on linac line DH at KEK Tsukuba.
      Answer in two short sentences.
      Use only the current that is still in this chat.
      Quote the current in nanoamperes.
      Do not invent a current.
    TEXT

    FOULED_QUESTION = <<~TEXT.strip
      Current ticket for Faraday cup DH, Wednesday 14 October 2026.
      Lab page: https://www.kek.jp/
      Faraday cup under the beam: 14 nA.
      The cup is on station. Record the current on the ticket.
    TEXT

    CORRECTED_QUESTION = <<~TEXT.strip
      The cup was fouled on a stray secondary. That 14 nA reading is retracted.
      Corrected Faraday cup under DH: 22 nA.
      What current goes on the ticket?
    TEXT

    Result = Struct.new(
      :fouled,
      :corrected,
      :roles_before_trim,
      :roles_after_trim,
      :roles,
      :trimmed_still_has_fouled,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      fouled = chat.ask(FOULED_QUESTION)
      roles_before_trim = chat.messages.map(&:role)

      system = chat.messages.first
      chat.messages = [system]
      roles_after_trim = chat.messages.map(&:role)
      corrected = chat.ask(CORRECTED_QUESTION)

      Result.new(
        fouled: fouled.content,
        corrected: corrected.content,
        roles_before_trim: roles_before_trim,
        roles_after_trim: roles_after_trim,
        roles: chat.messages.map(&:role),
        trimmed_still_has_fouled: chat.messages.any? { |message|
          message.content.to_s.include?("Faraday cup under the beam: 14 nA.")
        }
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "retracted_current") do
    result = TsukubaCupRetract::RetractedCurrent.conduct
  end

  puts result.fouled
  puts
  puts result.corrected
end
