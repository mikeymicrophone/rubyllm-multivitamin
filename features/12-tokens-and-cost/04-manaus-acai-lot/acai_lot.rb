# frozen_string_literal: true

# Tokens and cost · 04 · Manaus açaí lot versus hail
#
# Teaches:
# - Two chats, same instructions, different user prompts.
# - The longer lot card reports more input tokens than the one-line hail.
# - Output caps are left unset. The comparison is the prompt size.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ManausAcaiLot
  # The lot clerk at the Manaus açaí shed reads a full lot card, then a
  # one-line hail, on two separate chats. The desk compares the input
  # tokens.
  class AcaiLot
    INSTRUCTIONS = <<~TEXT.strip
      You are the lot clerk at the açaí shed on the Manaus riverfront.
      Answer in one short sentence.
      Use only the card in the question.
      Name shed G-7 and lot AMZ-441.
      Do not invent a berry count.
    TEXT

    LOT_CARD = <<~TEXT.strip
      Manaus açaí harvest log, shed G-7, Friday 16 October 2026.
      Market page: https://www.manaus.am.gov.br/
      River notes: https://www.portodemanaus.com.br/
      Lot AMZ-441, 18 baskets of açaí, 612 kilos landed at 07:40.
      Pulp 48 Brix. Current flooding past the Educandos channel.
      The cart Negro is alongside with the rinse crew.
      Hold tag signed by skipper Quilombo.
      The Belém buyer wants the lot number and the basket count.
      What is the lot, and how many baskets?
    TEXT

    HAIL = "Lot AMZ-441 on shed G-7: how many baskets?"

    Result = Struct.new(
      :lot_brief,
      :hail_brief,
      :lot_input,
      :hail_input,
      :lot_output,
      :hail_output,
      keyword_init: true
    )

    def self.conduct
      configure

      lot_chat = open_chat
      lot_chat.with_instructions(INSTRUCTIONS)
      lot_chat.with_temperature(0.2)
      lot = lot_chat.ask(LOT_CARD)

      hail_chat = open_chat
      hail_chat.with_instructions(INSTRUCTIONS)
      hail_chat.with_temperature(0.2)
      hail = hail_chat.ask(HAIL)

      Result.new(
        lot_brief: lot.content,
        hail_brief: hail.content,
        lot_input: lot.tokens.input,
        hail_input: hail.tokens.input,
        lot_output: lot.tokens.output,
        hail_output: hail.tokens.output
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "acai_lot") do
    result = ManausAcaiLot::AcaiLot.conduct
  end

  puts "lot in=#{result.lot_input}:"
  puts result.lot_brief
  puts
  puts "hail in=#{result.hail_input}:"
  puts result.hail_brief
end
