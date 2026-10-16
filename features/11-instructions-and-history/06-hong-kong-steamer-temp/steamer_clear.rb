# frozen_string_literal: true

# Instructions and history · 06 · Hong Kong steamer temperature cleared
#
# Teaches:
# - with_temperature(0.1) sends temperature on the first request.
# - with_temperature(nil) clears the override.
# - The next request omits the field.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module HongKongSteamerTemp
  # The family kitchen in Sham Shui Po holds the siu-mai steamer under a
  # tight temperature, then clears sampling before asking about the har-gow.
  class SteamerClear
    INSTRUCTIONS = <<~TEXT.strip
      You are the kitchen clerk at the Chan family dim-sum kitchen in Sham Shui Po, Hong Kong.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the steam board in this chat.
      Do not invent a pressure.
    TEXT

    SIU_MAI_QUESTION = <<~TEXT.strip
      Steam board at the Chan kitchen, Sham Shui Po, Wednesday 14 October 2026, 06:40.
      Kitchen page: https://www.fehd.gov.hk/
      Steam across the siu-mai basket: 22 kPa.
      Peak: 31 kPa.
      The 07:10 round is the siu-mai. The board says hold it.
      Should the kitchen clerk hold the 07:10 siu-mai?
    TEXT

    HAR_GOW_QUESTION = <<~TEXT.strip
      The 07:50 round is the har-gow.
      The later peak line is 18 kPa, and the board no longer says hold.
      Should the clerk let the 07:50 har-gow go?
    TEXT

    Result = Struct.new(
      :siu_mai,
      :har_gow,
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
      siu_mai = chat.ask(SIU_MAI_QUESTION)
      held_temperature = chat.temperature

      chat.with_temperature(nil)
      cleared_temperature = chat.temperature
      har_gow = chat.ask(HAR_GOW_QUESTION)

      Result.new(
        siu_mai: siu_mai.content,
        har_gow: har_gow.content,
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
  Multivitamin::Cassettes.play(__dir__, "steamer_clear") do
    result = HongKongSteamerTemp::SteamerClear.conduct
  end

  puts result.siu_mai
  puts
  puts result.har_gow
end
