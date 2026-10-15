# frozen_string_literal: true

# Streaming · 03 · Kathmandu brick kiln climb
#
# Teaches:
# - A temperature series is split across chunks.
# - Joining the chunks reproduces the message ask returns.
# - The returned message is the assistant turn on the chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KathmanduKilnClimb
  # The fireman calls the come-up on kiln No. 2 in Bhaktapur. The clerk's
  # tape only matches the fire card once every chunk is joined.
  class KilnClimb
    INSTRUCTIONS = <<~TEXT.strip
      You are the kiln clerk at the Bhaktapur brick field outside Kathmandu.
      Call the come-up in one sentence that lists the four temperatures in order.
      Use only the fire card.
      Do not invent a temperature.
    TEXT

    CLIMB_QUESTION = <<~TEXT.strip
      Come-up card for Wednesday 14 October 2026, kiln No. 2, red facing bricks, rack 3.
      Field notes: https://www.bhaktapur.com/
      05:12, 180 C.
      05:18, 210 C.
      05:24, 240 C.
      05:31, 242 C, and the fire holds there.
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
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

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
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "kiln_climb") do
    result = KathmanduKilnClimb::KilnClimb.conduct
  end

  puts result.speech
end
