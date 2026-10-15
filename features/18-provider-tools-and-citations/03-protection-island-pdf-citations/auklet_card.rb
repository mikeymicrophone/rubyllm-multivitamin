# frozen_string_literal: true

# Provider tools and citations · 03 · Protection Island PDF citations
#
# Teaches:
# - with_citations is a chat flag. On gpt-4.1-mini the registry warns.
# - Attached PDF pages are still readable.
# - response.citations stays empty: this model does not cite documents.

require "logger"
require "ruby_llm"
require "stringio"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ProtectionIslandPdfCitations
  # The landing clerk at Protection Island reads the posted auklet card,
  # a one-page PDF, and asks for citations. OpenAI does not cite the page.
  class AukletCard
    CARD = File.expand_path("auklet-card.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the landing clerk at Protection Island.
      Answer in two short sentences from the posted card only.
      Include the auklet count, 10:46, and Alden.
      Do not invent a figure.
    TEXT

    QUESTION = <<~TEXT.strip
      Thursday 15 October 2026, Protection Island west landing.
      The PDF is the posted card. How many rhinoceros auklets are on the
      raft, and when does Alden clear the kelp ledge?
    TEXT

    Result = Struct.new(
      :brief,
      :citations,
      :warning,
      :finish,
      :cost,
      keyword_init: true
    )

    def self.conduct
      log = StringIO.new
      configure(log)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_citations
      brief = chat.ask(QUESTION, with: CARD)

      Result.new(
        brief: brief.content,
        citations: brief.citations,
        warning: log.string,
        finish: brief.finish_reason,
        cost: brief.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

    def self.configure(log)
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(log)
        config.logger.level = Logger::WARN
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "auklet_card") do
    result = ProtectionIslandPdfCitations::AukletCard.conduct
  end

  puts result.brief
  puts result.warning
end
