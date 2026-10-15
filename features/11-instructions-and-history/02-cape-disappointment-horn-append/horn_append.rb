# frozen_string_literal: true

# Instructions and history · 02 · Cape Disappointment horn rule appended
#
# Teaches:
# - with_instructions replaces by default.
# - append: true adds a second :system message instead of replacing.
# - Both system texts are sent on the next request.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentHornAppend
  # The horn tender at Cape Disappointment posts the blast card, then
  # appends the one-mile visibility rule before asking whether the horn
  # must run in fair weather that is actually thick.
  class HornAppend
    BLAST_CARD = <<~TEXT.strip
      You are the horn tender at Cape Disappointment Light.
      These are the posted blast-card orders.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the visibility card in the question.
      Do not invent a blast time.
    TEXT

    VISIBILITY_RULE = <<~TEXT.strip
      Appended visibility rule for this watch only:
      if visibility is under 1 mile, the horn must run even when the
      posted card says fair weather.
    TEXT

    VISIBILITY_QUESTION = <<~TEXT.strip
      Foghorn house at Cape Disappointment, Wednesday 14 October 2026, 07:10.
      Light list: https://www.navcen.uscg.gov/
      Posted blast card: 3 seconds on, 27 seconds silent.
      Weather line on the card: fair.
      Lookout reports visibility 0.6 mile in river haze off the bar.
      Must the horn run on this watch?
    TEXT

    Result = Struct.new(
      :brief,
      :roles,
      :system_texts,
      :finish,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(BLAST_CARD)
      chat.with_instructions(VISIBILITY_RULE, append: true)
      chat.with_temperature(0.2)
      brief = chat.ask(VISIBILITY_QUESTION)

      Result.new(
        brief: brief.content,
        roles: chat.messages.map(&:role),
        system_texts: chat.messages.select { |message| message.role == :system }.map(&:content),
        finish: brief.finish_reason,
        cost: brief.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "horn_append") do
    result = CapeDisappointmentHornAppend::HornAppend.conduct
  end

  puts result.brief
end
