# frozen_string_literal: true

# Instructions and history · 04 · Anacortes late-basket follow-up
#
# Teaches:
# - A second ask on the same chat sends the earlier cook card back.
# - The follow-up does not repeat the card, and the answer still uses it.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesBasketFollowUp
  # The retort clerk at the Anacortes cannery logs which basket was late,
  # then asks for that basket's come-up without pasting the card again.
  class BasketFollowUp
    INSTRUCTIONS = <<~TEXT.strip
      You are the retort clerk at the Anacortes cannery.
      The tender ties at the Port of Anacortes marina, https://www.portofanacortes.com/.
      Answer in two short sentences.
      Use only the cook card in this chat.
      Do not invent baskets or times.
    TEXT

    COOK_QUESTION = <<~TEXT.strip
      Morning cook card for Wednesday 14 October 2026, retort No. 4.
      Product: pink halves.
      Basket 4, come-up 05:55, on time.
      Basket 7, come-up 06:40, late. The retort man Calder held it for a
      stuck lid dog.
      Basket 9, come-up 07:05, on time.
      Posted cook 75 minutes at 242 F.
      Which basket was late?
    TEXT

    FOLLOW_UP = "What time did that late basket start come-up?"

    Result = Struct.new(
      :late_basket,
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
      late_basket = chat.ask(COOK_QUESTION)
      come_up = chat.ask(FOLLOW_UP)

      Result.new(
        late_basket: late_basket.content,
        come_up: come_up.content,
        roles: chat.messages.map(&:role),
        follow_up_text: chat.messages.select { |message| message.role == :user }.last.content,
        card_still_present: chat.messages.any? { |message|
          message.role == :user && message.content.include?("Basket 7")
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
  Multivitamin::Cassettes.play(__dir__, "basket_follow_up") do
    result = AnacortesBasketFollowUp::BasketFollowUp.conduct
  end

  puts result.late_basket
  puts
  puts result.come_up
end
