# frozen_string_literal: true

# Chat basics · 10 · Port Townsend ferry slip wind board
#
# Teaches:
# - with_temperature and with_max_output_tokens are per chat.
# - A second chat can leave both unset, so the request omits them
#   and the model uses its own defaults.
# - The same wind board can be asked on each chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PortTownsendSlip
  # The slip clerk posts the wind twice: once with sampling and an output
  # cap set on the chat, and once with both left at the model's default.
  class WindBoard
    INSTRUCTIONS = <<~TEXT.strip
      You are the slip clerk at the Port Townsend ferry terminal.
      Answer in two short sentences.
      Use only the wind board in the question.
      Include the gust number and the sailing name Salish.
      Say whether the clerk holds that sailing.
      Do not invent a different gust.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Wind board at the Port Townsend slip, 1301 Water Street, Wednesday 14 October 2026, 06:40.
      Terminal page: https://wsdot.wa.gov/ferries.
      Wind across the slip: SW 22 knots.
      Gust: 31 knots.
      The 07:10 sailing is the Salish, and the board says hold her.
      A small-craft advisory is already posted on the board.
      Should the slip clerk hold the 07:10 Salish sailing, and what is the gust?
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
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "wind_board") do
    result = PortTownsendSlip::WindBoard.conduct
  end

  puts "temperature #{result.held_temperature}, cap #{result.held_output_cap}:"
  puts result.held
  puts
  puts "temperature #{result.unset_temperature.inspect}, cap #{result.unset_output_cap.inspect}:"
  puts result.unset
end
