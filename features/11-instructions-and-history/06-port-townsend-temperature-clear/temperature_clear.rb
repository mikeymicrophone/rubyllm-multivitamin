# frozen_string_literal: true

# Instructions and history · 06 · Port Townsend temperature cleared
#
# Teaches:
# - with_temperature(0.1) sends temperature on the first request.
# - with_temperature(nil) clears the override.
# - The next request omits the field.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendTemperatureClear
  # The slip clerk at Port Townsend holds the Salish under a tight
  # temperature, then clears sampling before asking about the Chetzemoka.
  class TemperatureClear
    INSTRUCTIONS = <<~TEXT.strip
      You are the slip clerk at the Port Townsend ferry terminal.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the wind board in this chat.
      Do not invent a gust.
    TEXT

    SALISH_QUESTION = <<~TEXT.strip
      Wind board at the Port Townsend slip, 1301 Water Street, Wednesday 14 October 2026, 06:40.
      Terminal page: https://wsdot.wa.gov/ferries
      Wind across the slip: SW 22 knots.
      Gust: 31 knots.
      The 07:10 sailing is the Salish. The board says hold her.
      Should the slip clerk hold the 07:10 Salish?
    TEXT

    CHETZEMOKA_QUESTION = <<~TEXT.strip
      The 07:50 sailing is the Chetzemoka.
      The later gust line is 18 knots, and the board no longer says hold.
      Should the clerk let the 07:50 Chetzemoka go?
    TEXT

    Result = Struct.new(
      :salish,
      :chetzemoka,
      :held_temperature,
      :cleared_temperature,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.1)
      salish = chat.ask(SALISH_QUESTION)
      held_temperature = chat.temperature

      chat.with_temperature(nil)
      cleared_temperature = chat.temperature
      chetzemoka = chat.ask(CHETZEMOKA_QUESTION)

      Result.new(
        salish: salish.content,
        chetzemoka: chetzemoka.content,
        held_temperature: held_temperature,
        cleared_temperature: cleared_temperature,
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "temperature_clear") do
    result = PortTownsendTemperatureClear::TemperatureClear.conduct
  end

  puts result.salish
  puts
  puts result.chetzemoka
end
