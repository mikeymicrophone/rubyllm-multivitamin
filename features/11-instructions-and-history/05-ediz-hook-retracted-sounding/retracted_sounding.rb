# frozen_string_literal: true

# Instructions and history · 05 · Ediz Hook retracted sounding
#
# Teaches:
# - chat.messages is the transcript the next request will send.
# - Assigning messages drops a retracted user and assistant turn.
# - The next request body no longer carries the bad sounding.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EdizHookRetractedSounding
  # The buoy tender off Ediz Hook logs a fouled lead of 14 ft under DH,
  # then retracts that pair from the transcript before posting the
  # corrected 22 ft sounding.
  class RetractedSounding
    INSTRUCTIONS = <<~TEXT.strip
      You are the buoy tender working the lighted bell buoy off Ediz Hook.
      Answer in two short sentences.
      Use only the sounding that is still in this chat.
      Quote the depth in feet.
      Do not invent a sounding.
    TEXT

    FOULED_QUESTION = <<~TEXT.strip
      Sounding ticket for lighted bell buoy DH, Wednesday 14 October 2026.
      Light list: https://www.navcen.uscg.gov/
      Lead line under the buoy: 14 ft.
      The can is on station. Record the depth on the ticket.
    TEXT

    CORRECTED_QUESTION = <<~TEXT.strip
      The lead was fouled on kelp. That 14 ft sounding is retracted.
      Corrected lead line under DH: 22 ft.
      What depth goes on the ticket?
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
          message.content.to_s.include?("Lead line under the buoy: 14 ft.")
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
  Multivitamin::Cassettes.play(__dir__, "retracted_sounding") do
    result = EdizHookRetractedSounding::RetractedSounding.conduct
  end

  puts result.fouled
  puts
  puts result.corrected
end
