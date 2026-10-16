# frozen_string_literal: true

# Configuration and contexts · 09 · Asunción harp sampling and params
#
# Teaches:
# - with_temperature is a per-chat override. It is not a Configuration option.
# - with_provider_options is the 2.1.1 name for extra request fields. There
#   is no with_params on Chat.
# - A second chat can leave both unset, so the wire omits them.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module AsuncionHarpSampling
  # The recording clerk at the Asunción harp desk posts the detune
  # twice: once with temperature and top_p set on the chat, once with
  # both left to the model.
  class HarpSampling
    HELD_TEMPERATURE = 0.1
    HELD_TOP_P = 0.2

    INSTRUCTIONS = <<~TEXT.strip
      You are the recording clerk at the folkloric harp desk in Asunción.
      Answer in two short sentences.
      Use only the tuning board in the question.
      Include the 31 and Pájaro Campana.
      Say whether the clerk holds that take.
      Do not invent a different detune.
    TEXT

    BOARD_QUESTION = <<~TEXT.strip
      Tuning board at the Asunción harp desk, Wednesday 14 October 2026, 06:40.
      Municipal page: https://www.asuncion.gov.py/.
      First-string detune: 31 cents sharp.
      The morning take is Pájaro Campana, and the board says hold it.
      Should the clerk hold the Pájaro Campana take, and what is the detune?
    TEXT

    Result = Struct.new(
      :held,
      :unset,
      :held_temperature,
      :unset_temperature,
      :held_options,
      :unset_options,
      :responds_to_params,
      :responds_to_provider_options,
      keyword_init: true
    )

    def self.conduct
      configure

      held = open_chat
      held.with_instructions(INSTRUCTIONS)
      held.with_temperature(HELD_TEMPERATURE)
      held.with_provider_options(top_p: HELD_TOP_P)
      held_reply = held.ask(BOARD_QUESTION)

      unset = open_chat
      unset.with_instructions(INSTRUCTIONS)
      unset_reply = unset.ask(BOARD_QUESTION)

      Result.new(
        held: held_reply.content,
        unset: unset_reply.content,
        held_temperature: held.temperature,
        unset_temperature: unset.temperature,
        held_options: held.provider_options,
        unset_options: unset.provider_options,
        responds_to_params: held.respond_to?(:with_params),
        responds_to_provider_options: held.respond_to?(:with_provider_options)
      )
    end

    def self.open_chat
      ConfigurationPaidOpenrouter.prepare(
        RubyLLM.chat(**ConfigurationPaidOpenrouter.chat_args)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "harp_sampling") do
    result = AsuncionHarpSampling::HarpSampling.conduct
  end

  puts "held temperature #{result.held_temperature} top_p #{result.held_options[:top_p]}:"
  puts result.held
  puts
  puts "unset:"
  puts result.unset
end
