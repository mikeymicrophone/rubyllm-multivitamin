# frozen_string_literal: true

# Instructions and history · 13 · Macau fuse-house shift reset
#
# Teaches:
# - Assigning messages = [] resets the conversation on the same chat.
# - New with_instructions after the reset is the only system prompt.
# - The next ask does not see the overnight board.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MacauFuseReset
  # The overnight clerk at a Coloane firework workshop briefs the fuse
  # house, then the morning relief resets the transcript, posts new
  # orders, and asks when packer Mei-Ling can leave the packing bench.
  class ShiftReset
    NIGHT_ORDERS = <<~TEXT.strip
      You are the overnight fuse clerk at a firework workshop in Coloane, Macau.
      These are the overnight standing orders.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Name whether the fuse house is running.
      Do not invent a burn time.
    TEXT

    MORNING_ORDERS = <<~TEXT.strip
      You are the morning relief at a firework workshop in Coloane, Macau.
      These are the morning standing orders.
      Answer in two short sentences.
      Name the clock time Mei-Ling leaves.
      Do not invent a charge weight.
    TEXT

    NIGHT_QUESTION = <<~TEXT.strip
      Overnight board at the Coloane workshop, Wednesday night 14 October 2026.
      Tourism page: https://www.macaotourism.gov.mo/
      Low charge 07:05, 1.1 g.
      Humidity 1 percent over the band, so the fuse house is running.
      Burn 3 seconds, silent 27 seconds.
      Is the fuse house running?
    TEXT

    MORNING_QUESTION = <<~TEXT.strip
      Morning board at the Coloane workshop, Thursday 15 October 2026.
      Low charge 06:42, 0.4 g above the posted floor.
      High charge 12:18, 8.1 g.
      The packer Mei-Ling clears the packing bench at 10:46.
      The powder cabinet is closed.
      When can Mei-Ling leave the bench?
    TEXT

    Result = Struct.new(
      :night,
      :morning,
      :roles_after_reset,
      :roles,
      :night_finish,
      :morning_finish,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(NIGHT_ORDERS)
      chat.with_temperature(0.2)
      night = chat.ask(NIGHT_QUESTION)

      chat.messages = []
      chat.with_instructions(MORNING_ORDERS)
      roles_after_reset = chat.messages.map(&:role)
      morning = chat.ask(MORNING_QUESTION)

      Result.new(
        night: night.content,
        morning: morning.content,
        roles_after_reset: roles_after_reset,
        roles: chat.messages.map(&:role),
        night_finish: night.finish_reason,
        morning_finish: morning.finish_reason
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
  Multivitamin::Cassettes.play(__dir__, "shift_reset") do
    result = MacauFuseReset::ShiftReset.conduct
  end

  puts result.night
  puts
  puts result.morning
end
