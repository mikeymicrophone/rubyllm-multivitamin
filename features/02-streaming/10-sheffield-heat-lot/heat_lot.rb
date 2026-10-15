# frozen_string_literal: true

# Streaming · 10 · Sheffield cutlery heat-lot
#
# Teaches:
# - A lot code can be flushed in the middle of the code.
# - The label is the joined chunks, which is the returned message.
# - A word beside a number may be separated by U+202F, which \s does not match.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SheffieldHeatLot
  # The stamp clerk at the Kelham Island cutlery works streams the heat-lot
  # code for the morning run of table knives. The code is read after the
  # chunks join.
  class HeatLot
    LOT_CODE = "SHF-2026-1014-R2-B3"

    INSTRUCTIONS = <<~TEXT.strip
      You are the stamp clerk at the Kelham Island cutlery works in Sheffield.
      Write two short sentences.
      The first sentence contains the lot code exactly as given.
      The second sentence names rack 3 and furnace No. 2.
      Do not invent a code.
    TEXT

    LABEL_QUESTION = <<~TEXT.strip
      Label for Wednesday 14 October 2026, morning heat, table knives.
      Works notes: https://www.simt.co.uk/kelham-island-museum
      Lot code: SHF-2026-1014-R2-B3.
      Rack 3. Furnace No. 2. Soak 75 minutes at 242 C.
      Write the label copy.
    TEXT

    Result = Struct.new(:speech, :pieces, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      pieces = []
      message = chat.ask(LABEL_QUESTION) do |chunk|
        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      Result.new(speech: message.content, pieces: pieces)
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "heat_lot") do
    result = SheffieldHeatLot::HeatLot.conduct
  end

  puts result.speech
  puts
  result.pieces.each_with_index { |piece, index| puts format("%02d %s", index, piece.inspect) }
end
