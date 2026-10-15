# frozen_string_literal: true

# Structured output · 12 · Alexandria papyrus reject
#
# Teaches:
# - OpenAI strict mode rejects a schema that marks strict true while a
#   property is left out of required.
# - A required field that may be null uses anyOf of string and null, and
#   stays in required, so strict can stay true.
# - The application rejects a parsed notice that dropped the shelfmark.
# - supports?(:structured_output) and supports?(:judgment) are registry
#   checks. whisper-1 has neither. gpt-4.1-mini has structured output and
#   not judgment. gpt-6-luna has both, and judgment is Decisions, not
#   with_schema.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AlexandriaPapyrusReject
  class MissingShelfmark < StandardError
  end

  # strict: true with findspot optional. OpenAI's Responses API rejects this.
  BROKEN_SCHEMA = {
    name: "PapyrusCorrection",
    strict: true,
    schema: {
      type: "object",
      properties: {
        shelfmark: { type: "string", description: "Papyrus the notice names" },
        notice: { type: "string", description: "Notice number" },
        findspot: { type: "string", description: "Findspot, only when the notice gives one" }
      },
      required: %w[shelfmark notice],
      additionalProperties: false
    }
  }.freeze

  class PapyrusNotice < Schematist::Schema
    title "papyrus_notice"
    description "One Alexandria papyrus correction"

    string :shelfmark, description: "The papyrus the notice names"
    string :notice, description: "Notice number"
    any_of :findspot, description: "Findspot if the notice gives one, otherwise null" do
      string
      null
    end
  end

  class NoticeDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the clerk correcting the Alexandria papyrus catalogue.
      Fill the schema from the notice. Copy the shelfmark and the notice number.
      The notice gives no findspot, so findspot is null.
    TEXT

    BROKEN_QUESTION = <<~TEXT.strip
      Notice 1842. Shelfmark: Zenon. No findspot on this notice.
    TEXT

    NOTICE = <<~TEXT.strip
      Wednesday 14 October 2026, catalogue desk for the Bibliotheca Alexandrina.
      Catalogue: https://www.bibalex.org/
      Notice desk: https://www.papyrology.org/
      Notice 1842. Shelfmark: Zenon.
      Move the fragment note 0.2 centimetre left. No findspot is printed.
    TEXT

    Result = Struct.new(
      :rejection_class, :rejection_message, :parsed, :roles, :finish,
      keyword_init: true
    )

    def self.accept_notice(notice)
      shelfmark = notice["shelfmark"].to_s.strip
      raise MissingShelfmark, "The notice dropped the shelfmark" if shelfmark.empty?

      notice
    end

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      rejection = nil
      chat.with_schema(BROKEN_SCHEMA)
      begin
        chat.ask(BROKEN_QUESTION)
      rescue RubyLLM::Error => error
        rejection = error
      end

      chat.with_schema(PapyrusNotice)
      answer = chat.ask(NOTICE)
      accept_notice(answer.parsed)

      Result.new(
        rejection_class: rejection&.class,
        rejection_message: rejection&.message,
        parsed: answer.parsed,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason
      )
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
  Multivitamin::Cassettes.play(__dir__, "papyrus_reject") do
    result = AlexandriaPapyrusReject::NoticeDesk.conduct
  end

  puts "#{result.rejection_class}: #{result.rejection_message}"
  puts JSON.generate(result.parsed)
end
