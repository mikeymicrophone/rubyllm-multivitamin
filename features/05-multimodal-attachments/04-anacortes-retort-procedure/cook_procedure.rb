# frozen_string_literal: true

# Multimodal attachments · 04 · Anacortes retort cook procedure
#
# Teaches:
# - ask takes a PDF with with:.
# - No free OpenRouter chat model advertised file input, so this uses OpenAI.
# - A PDF under the Responses inline limit stays in the request as file_data.
#   auto_upload_large_files is on, and this card does not reach the files API.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesRetortProcedure
  # The cook card is a one-page PDF on the cannery desk. The clerk reads
  # basket, temperature, and hold from the page.
  class CookProcedure
    CARD = File.expand_path("cook-procedure.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the retort clerk at the Anacortes cannery.
      Answer in one sentence from the procedure only.
      Include the basket number, the temperature in F, and the hold in minutes.
      Do not invent a figure.
    TEXT

    COOK_QUESTION = "What basket is on the procedure, what temperature does it come up to, and how long is the hold?"

    Result = Struct.new(:card, :byte_size, :inline_limit, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      card = chat.ask(COOK_QUESTION, with: CARD)
      attachment = chat.messages.find { |message| message.role == :user }.attachments.first

      Result.new(
        card: card.content,
        byte_size: attachment.byte_size,
        inline_limit: RubyLLM::Protocols::Responses::Chat::OPENAI_INLINE_FILE_LIMIT,
        finish: card.finish_reason,
        input_tokens: card.tokens.input,
        cost: card.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      chat.with_temperature(0)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        # On by default. A PDF over the inline limit uploads. This card does not.
        config.auto_upload_large_files = true
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
  Multivitamin::Cassettes.play(__dir__, "cook_procedure") do
    result = AnacortesRetortProcedure::CookProcedure.conduct
  end

  puts result.card
end
