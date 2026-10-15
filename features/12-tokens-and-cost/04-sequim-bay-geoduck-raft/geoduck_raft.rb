# frozen_string_literal: true

# Tokens and cost · 04 · Sequim Bay geoduck raft versus hail
#
# Teaches:
# - Two chats, same instructions, different user prompts.
# - The longer harvest log reports more input tokens than the one-line hail.
# - Output caps are left unset. The comparison is the prompt size.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SequimBayGeoduckRaft
  # The harvest clerk at the Sequim Bay geoduck raft reads a full lot
  # card, then a one-line hail, on two separate chats. The watch compares
  # the input tokens.
  class GeoduckRaft
    INSTRUCTIONS = <<~TEXT.strip
      You are the harvest clerk on the Sequim Bay geoduck raft off Gibson Spit.
      Answer in one short sentence.
      Use only the card in the question.
      Name raft G-7 and lot SQB-441.
      Do not invent a siphon count.
    TEXT

    LOT_CARD = <<~TEXT.strip
      Sequim Bay geoduck harvest log, raft G-7, Wednesday 14 October 2026.
      County page: https://www.clallamcountywa.gov/
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Lot SQB-441, 18 sacks of geoduck, 612 pounds landed at 07:40.
      Water 48 F. Current flooding 1.4 knots past Gibson Spit.
      The skiff Manila is alongside with the siphon crew.
      Hold tag signed by skipper Quillayute.
      The Port Angeles buyer wants the lot number and the sack count.
      What is the lot, and how many sacks?
    TEXT

    HAIL = "Lot SQB-441 on raft G-7: how many sacks?"

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
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "geoduck_raft") do
    result = SequimBayGeoduckRaft::GeoduckRaft.conduct
  end

  puts "lot in=#{result.lot_input}:"
  puts result.lot_brief
  puts
  puts "hail in=#{result.hail_input}:"
  puts result.hail_brief
end
