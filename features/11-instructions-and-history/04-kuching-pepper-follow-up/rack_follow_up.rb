# frozen_string_literal: true

# Instructions and history · 04 · Kuching late-rack follow-up
#
# Teaches:
# - A second ask on the same chat sends the earlier drying card back.
# - The follow-up does not repeat the card, and the answer still uses it.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KuchingPepperFollowUp
  # The loft clerk at a Kuching pepper house logs which drying rack was
  # late, then asks for that rack's come-up without pasting the card again.
  class RackFollowUp
    INSTRUCTIONS = <<~TEXT.strip
      You are the loft clerk at a white-pepper house on the Sarawak River in Kuching.
      The board hangs above the smoke racks, https://www.sarawak.gov.my/.
      Answer in two short sentences.
      Use only the drying card in this chat.
      Do not invent racks or times.
    TEXT

    DRYING_QUESTION = <<~TEXT.strip
      Morning drying card for Wednesday 14 October 2026, loft No. 4.
      Product: Sarawak white pepper, bunches from Sematan.
      Rack 4, come-up 05:55, on time.
      Rack 7, come-up 06:40, late. The smoke man Ahmad held it for a
      stuck flue damper.
      Rack 9, come-up 07:05, on time.
      Posted dry 75 minutes at 42 C.
      Which rack was late?
    TEXT

    FOLLOW_UP = "What time did that late rack start come-up?"

    Result = Struct.new(
      :late_rack,
      :come_up,
      :roles,
      :follow_up_text,
      :card_still_present,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      late_rack = chat.ask(DRYING_QUESTION)
      come_up = chat.ask(FOLLOW_UP)

      Result.new(
        late_rack: late_rack.content,
        come_up: come_up.content,
        roles: chat.messages.map(&:role),
        follow_up_text: chat.messages.select { |message| message.role == :user }.last.content,
        card_still_present: chat.messages.any? { |message|
          message.role == :user && message.content.include?("Rack 7")
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
  Multivitamin::Cassettes.play(__dir__, "rack_follow_up") do
    result = KuchingPepperFollowUp::RackFollowUp.conduct
  end

  puts result.late_rack
  puts
  puts result.come_up
end
