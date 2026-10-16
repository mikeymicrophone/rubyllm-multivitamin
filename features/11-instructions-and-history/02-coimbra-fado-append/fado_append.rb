# frozen_string_literal: true

# Instructions and history · 02 · Coimbra fado humidity rule appended
#
# Teaches:
# - with_instructions replaces by default.
# - append: true adds a second :system message instead of replacing.
# - Both system texts are sent on the next request.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CoimbraFadoAppend
  # The hall keeper at a Coimbra fado loft posts the tuning card, then
  # appends the humidity rule before asking whether the hall must stay
  # shut when the card says fair and the hygrometer is already low.
  class FadoAppend
    HALL_CARD = <<~TEXT.strip
      You are the hall keeper at a fado loft on Rua da Sofia in Coimbra.
      These are the posted hall-card orders.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the humidity card in the question.
      Do not invent a tuning time.
    TEXT

    HUMIDITY_RULE = <<~TEXT.strip
      Appended humidity rule for this rehearsal only:
      if relative humidity is under 40 percent, the hall must stay shut
      even when the posted card says fair.
    TEXT

    HUMIDITY_QUESTION = <<~TEXT.strip
      Fado loft on Rua da Sofia, Coimbra, Wednesday 14 October 2026, 07:10.
      Conservatório: https://www.cm-coimbra.pt/
      Posted hall card: guitarra tuning 3 minutes on, 27 minutes silent.
      Weather line on the card: fair.
      Lookout reports relative humidity 36 percent in river haze off the Mondego.
      Must the hall stay shut on this rehearsal?
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
      chat.with_instructions(HALL_CARD)
      chat.with_instructions(HUMIDITY_RULE, append: true)
      chat.with_temperature(0.2)
      brief = chat.ask(HUMIDITY_QUESTION)

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
  Multivitamin::Cassettes.play(__dir__, "fado_append") do
    result = CoimbraFadoAppend::FadoAppend.conduct
  end

  puts result.brief
end
