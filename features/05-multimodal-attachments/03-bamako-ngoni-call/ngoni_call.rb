# frozen_string_literal: true

# Multimodal attachments · 03 · Bamako ngoni call
#
# Teaches:
# - ask takes an audio file with with:.
# - The model has to be one that accepts audio. gpt-4.1-mini does not.
# - The recording stays on the user message as an Attachment.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BamakoNgoniCall
  # Amadou phones the booth from Studio BKO. The clerk logs the call from
  # the recording, not from memory.
  class NgoniCall
    RECORDING = File.expand_path("ngoni-call.mp3", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the booth clerk at Studio BKO in Bamako.
      Report what the recording says. Do not give the session new orders.
      Include the studio, the take count, and the reverb.
    TEXT

    CALL_QUESTION = "What studio is calling, how many takes, and what reverb did Amadou report?"

    Result = Struct.new(:log_line, :roles, :attachment_type, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      log_line = chat.ask(CALL_QUESTION, with: RECORDING)
      user = chat.messages.find { |message| message.role == :user }

      Result.new(
        log_line: log_line.content,
        roles: chat.messages.map(&:role),
        attachment_type: user.attachments.first&.type,
        finish: log_line.finish_reason,
        input_tokens: log_line.tokens.input,
        cost: log_line.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "ngoni_call") do
    result = BamakoNgoniCall::NgoniCall.conduct
  end

  puts result.log_line
end
