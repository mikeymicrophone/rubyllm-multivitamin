# frozen_string_literal: true

# Multimodal attachments · 07 · Ediz Hook buoy check-in
#
# Teaches:
# - A follow-up ask with no new file still sends the earlier recording.
# - The first user message keeps the attachment. The second user message
#   has none. The wire still carries the audio on the first turn.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EdizHookBuoyCheckIn
  # Alden checks in from the buoy tender. The second question is only
  # the battery voltage, and the recording is not attached again.
  class BuoyCheckIn
    RECORDING = File.expand_path("buoy-check-in.mp3", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the buoy watch at Ediz Hook.
      Report what the recording says. Do not add a task the tender did not call.
      Name Alden when you log the check-in.
    TEXT

    CHECK_IN = "Log the check-in. Include the clock time and the battery voltage."
    VOLTAGE = "What voltage did Alden call? Reply with the number of volts only."

    Result = Struct.new(
      :check_in,
      :voltage,
      :roles,
      :attachment_counts,
      :finish,
      :input_tokens,
      :follow_up_input_tokens,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      check_in = chat.ask(CHECK_IN, with: RECORDING)
      voltage = chat.ask(VOLTAGE)
      users = chat.messages.select { |message| message.role == :user }

      Result.new(
        check_in: check_in.content,
        voltage: voltage.content,
        roles: chat.messages.map(&:role),
        attachment_counts: users.map { |message| message.attachments.length },
        finish: voltage.finish_reason,
        input_tokens: check_in.tokens.input,
        follow_up_input_tokens: voltage.tokens.input
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_AUDIO, provider: :openai)
      chat.with_temperature(0)
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
  Multivitamin::Cassettes.play(__dir__, "buoy_check_in") do
    result = EdizHookBuoyCheckIn::BuoyCheckIn.conduct
  end

  puts result.check_in
  puts result.voltage
end
