# frozen_string_literal: true

# MCP client · 06 · Ediz Hook resource attachment
#
# Teaches:
# - MCP resources are files as far as RubyLLM is concerned.
# - resource(uri) reads through the server, never the URI itself.
# - ask(..., with: resource) attaches that card like any other file.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module EdizHookMcpResource
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class EdizHookBuoyDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
  end

  class BuoyCard
    INSTRUCTIONS = <<~TEXT.strip
      You are the buoy clerk at Ediz Hook.
      Answer in one sentence from the attached battery card only.
      Include the 14.8 V figure.
      Name buoy EH-2.
      Do not invent a voltage.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026 on the Ediz Hook spit.
      Station: https://www.portofpa.com/
      The attached card is the battery sheet for bell buoy EH-2.
      What voltage is posted, and should the bank be replaced tonight?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :uri,
      :mime_type,
      :filename,
      :card_text,
      :attachment_type,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = EdizHookBuoyDesk.new
      # Resource#to_attachment names the file from the URI path, not mimeType.
      # A watch:// path without an extension becomes application/octet-stream.
      card = desk.resource("watch://ediz-hook/buoy-battery.md")
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      answer = chat.ask(CARD_QUESTION, with: card)
      attachment = chat.messages.find { |message| message.role == :user }.attachments.first

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        uri: card.uri,
        mime_type: card.mime_type,
        filename: attachment&.filename,
        card_text: card.content,
        attachment_type: attachment&.type
      )
    ensure
      desk&.close
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
  Multivitamin::Cassettes.play(__dir__, "buoy_card") do
    result = EdizHookMcpResource::BuoyCard.conduct
  end

  puts result.answer
end
