# frozen_string_literal: true

# Tokens and cost · 12 · Kano indigo-halt cancelled usage
#
# Teaches:
# - chat.cancel raises CancelledError after the block. The assistant
#   turn is not appended.
# - The cancelled attempt still sits on chat.usage_entries.
# - If the stream stopped before a usage chunk, chat.cost.total is nil
#   rather than a fake zero.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KanoIndigoHalt
  # The dye clerk at the Kano indigo pits starts calling the four pit
  # figures and is stopped after two spoken pieces. The desk still has
  # to file whatever usage that attempt produced.
  class IndigoHalt
    INSTRUCTIONS = <<~TEXT.strip
      You are the dye clerk at the indigo pits in Kano.
      Call the four pit figures in order, one short sentence each.
      Use only the pit card.
    TEXT

    PIT_QUESTION = <<~TEXT.strip
      Kano indigo pit card, Friday 16 October 2026, morning dip.
      City notes: https://www.kanostate.gov.ng/
      Craft board: https://www.nigerianembassy.org/
      First call: vat 3.4 cubits at the north pit.
      Second call: 4.1 cubits in the mid yard toward Kurmi.
      Third call: 2.6 cubits off the south wall.
      Fourth call: rinse filling, and the buyer Halima holds south of the pits.
      Call the four figures.
    TEXT

    Result = Struct.new(
      :spoken,
      :error,
      :roles,
      :chat_input,
      :chat_output,
      :chat_cost,
      :attempt_status,
      :attempt_count,
      :attempt_input,
      :attempt_output,
      :attempt_reported,
      :message_token_sum,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

      spoken = []
      error = nil
      begin
        chat.ask(PIT_QUESTION) do |chunk|
          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          chat.cancel if spoken.size == 2
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      message_token_sum = chat.messages.sum { |message| message.tokens.input.to_i }
      attempt = chat.usage_entries.last

      Result.new(
        spoken: spoken,
        error: error,
        roles: chat.messages.map(&:role),
        chat_input: chat.tokens.input,
        chat_output: chat.tokens.output,
        chat_cost: chat.cost.total,
        attempt_status: attempt&.status,
        attempt_count: chat.usage_entries.size,
        attempt_input: attempt&.tokens&.input,
        attempt_output: attempt&.tokens&.output,
        attempt_reported: attempt&.tokens&.reported_cost,
        message_token_sum: message_token_sum
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "indigo_halt") do
    result = KanoIndigoHalt::IndigoHalt.conduct
  end

  puts result.spoken.join
  puts
  puts "#{result.error.class} status=#{result.attempt_status} chat_cost=#{result.chat_cost.inspect} " \
       "chat_in=#{result.chat_input.inspect}"
end
