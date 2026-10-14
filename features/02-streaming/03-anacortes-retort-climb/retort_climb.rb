# frozen_string_literal: true

# Streaming · 03 · Anacortes retort climb
#
# Teaches:
# - A temperature series is split across chunks.
# - Joining the chunks reproduces the message ask returns.
# - The returned message is the assistant turn on the chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesRetortClimb
  # The retort man calls the come-up on retort No. 2. The clerk's tape
  # only matches the cook card once every chunk is joined.
  class RetortClimb
    INSTRUCTIONS = <<~TEXT.strip
      You are the retort clerk at the Anacortes cannery.
      Call the come-up in one sentence that lists the four temperatures in order.
      Use only the cook card.
      Do not invent a temperature.
    TEXT

    CLIMB_QUESTION = <<~TEXT.strip
      Come-up card for Wednesday 14 October 2026, retort No. 2, sockeye halves, basket 3.
      The tender ties at the Port of Anacortes marina, https://www.portofanacortes.com/.
      05:12, 180 F.
      05:18, 210 F.
      05:24, 240 F.
      05:31, 242 F, and the cook holds there.
      Call the climb for the office.
    TEXT

    Result = Struct.new(
      :speech,
      :pieces,
      :same_message,
      :roles,
      :finish_reason,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

      pieces = []
      message = chat.ask(CLIMB_QUESTION) do |chunk|
        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      Result.new(
        speech: message.content,
        pieces: pieces,
        same_message: chat.messages.last.equal?(message),
        roles: chat.messages.map(&:role),
        finish_reason: message.finish_reason
      )
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
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
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "retort_climb") do
    result = AnacortesRetortClimb::RetortClimb.conduct
  end

  puts result.speech
end
