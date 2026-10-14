# frozen_string_literal: true

# Streaming · 10 · Anacortes cannery lot code
#
# Teaches:
# - A lot code can be flushed in the middle of the code.
# - The label is the joined chunks, which is the returned message.
# - A word beside a number may be separated by U+202F, which \s does not match.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesCanneryLotCode
  # The label clerk at the Anacortes cannery streams the lot code for the
  # morning cook of sockeye halves. The code is read after the chunks join.
  class LotCode
    LOT_CODE = "ANC-2026-1014-R2-B3"

    INSTRUCTIONS = <<~TEXT.strip
      You are the label clerk at the Anacortes cannery.
      Write two short sentences.
      The first sentence contains the lot code exactly as given.
      The second sentence names basket 3 and retort No. 2.
      Do not invent a code.
    TEXT

    LABEL_QUESTION = <<~TEXT.strip
      Label for Wednesday 14 October 2026, morning cook, sockeye halves.
      The tender ties at the Port of Anacortes marina, https://www.portofanacortes.com/.
      Lot code: ANC-2026-1014-R2-B3.
      Basket 3. Retort No. 2. Cook 75 minutes at 242 F.
      Write the label copy.
    TEXT

    Result = Struct.new(:speech, :pieces, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)

      pieces = []
      message = chat.ask(LABEL_QUESTION) do |chunk|
        piece = chunk.content.to_s
        pieces << piece unless piece.empty?
      end

      Result.new(speech: message.content, pieces: pieces)
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
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "lot_code") do
    result = AnacortesCanneryLotCode::LotCode.conduct
  end

  puts result.speech
  puts
  result.pieces.each_with_index { |piece, index| puts format("%02d %s", index, piece.inspect) }
end
