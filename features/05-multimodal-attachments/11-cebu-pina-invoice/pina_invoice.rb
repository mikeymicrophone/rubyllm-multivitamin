# frozen_string_literal: true

# Multimodal attachments · 11 · Cebu piña invoice
#
# Teaches:
# - The same PDF is sent again on a follow-up that attaches nothing.
# - The first user message keeps the invoice. The second has no attachment.
# - Both requests carry file_data. The invoice stays under the inline limit,
#   so neither request is a files upload.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CebuPinaInvoice
  # The embroidery shop asks twice about one invoice. The second question
  # does not attach the PDF again.
  class PinaInvoice
    INVOICE = File.expand_path("pina-invoice.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the clerk at a Cebu piña embroidery shop.
      Answer from the invoice only. Do not invent a figure.
    TEXT

    BOLT_QUESTION = "Which bolt is on the invoice, and what is the price in dollars? One sentence."
    METRES_QUESTION = "How many metres of that bolt are on the invoice? Reply with the number only."

    Result = Struct.new(
      :bolt,
      :metres,
      :attachment_counts,
      :byte_size,
      :finish,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      bolt = chat.ask(BOLT_QUESTION, with: INVOICE)
      metres = chat.ask(METRES_QUESTION)
      users = chat.messages.select { |message| message.role == :user }
      invoice = users.first.attachments.first

      Result.new(
        bolt: bolt.content,
        metres: metres.content,
        attachment_counts: users.map { |message| message.attachments.length },
        byte_size: invoice.byte_size,
        finish: metres.finish_reason,
        cost: metres.cost.total
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
  Multivitamin::Cassettes.play(__dir__, "pina_invoice") do
    result = CebuPinaInvoice::PinaInvoice.conduct
  end

  puts result.bolt
  puts result.metres
end
