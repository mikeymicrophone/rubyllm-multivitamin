# frozen_string_literal: true

# Chat basics · 10 · Brussels chocolate tempering board
#
# Teaches:
# - with_temperature and with_max_output_tokens are per chat.
# - A second chat can leave both unset, so the request omits them
#   and the model uses its own defaults.
# - The same tempering board can be asked on each chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BrusselsTempering
  # The chef de laboratoire posts the temper twice: once with sampling and
  # an output cap set on the chat, and once with both left at the model's default.
  class TemperingBoard
    INSTRUCTIONS = <<~TEXT.strip
      You are the chef de laboratoire at Atelier du Grand Sablon in Brussels.
      Answer in two short sentences.
      Use only the tempering board in the question.
      Include the crystal number and the pour name Praliné Roi.
      Say whether the chef holds that pour.
      Do not invent a different crystal temperature.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Tempering board at Atelier du Grand Sablon, Place du Grand Sablon, Wednesday 14 October 2026, 06:40.
      Atelier page: https://visit.brussels/.
      Working couverture: 32.2 C.
      Crystal: 31 C.
      The 07:10 pour is the Praliné Roi, and the board says hold her.
      A bloom warning is already posted on the board.
      Should the chef hold the 07:10 Praliné Roi pour, and what is the crystal temperature?
    TEXT

    HELD_OUTPUT_CAP = 2000

    Result = Struct.new(
      :held,
      :unset,
      :held_temperature,
      :unset_temperature,
      :held_output_cap,
      :unset_output_cap,
      keyword_init: true
    )

    def self.conduct
      configure

      held = open_chat
      held.with_instructions(INSTRUCTIONS)
      held.with_temperature(0.1)
      held.with_max_output_tokens(HELD_OUTPUT_CAP)
      held_reply = held.ask(BOARD_QUESTION)

      unset = open_chat
      unset.with_instructions(INSTRUCTIONS)
      unset_reply = unset.ask(BOARD_QUESTION)

      Result.new(
        held: held_reply.content,
        unset: unset_reply.content,
        held_temperature: held.temperature,
        unset_temperature: unset.temperature,
        held_output_cap: held.max_output_tokens,
        unset_output_cap: unset.max_output_tokens
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "tempering_board") do
    result = BrusselsTempering::TemperingBoard.conduct
  end

  puts "temperature #{result.held_temperature}, cap #{result.held_output_cap}:"
  puts result.held
  puts
  puts "temperature #{result.unset_temperature.inspect}, cap #{result.unset_output_cap.inspect}:"
  puts result.unset
end
