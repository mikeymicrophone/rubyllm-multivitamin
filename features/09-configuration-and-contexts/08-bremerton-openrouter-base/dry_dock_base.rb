# frozen_string_literal: true

# Configuration and contexts · 08 · Bremerton OpenRouter base URL
#
# Teaches:
# - openrouter_api_base on a context is the host the cassette records.
# - http_proxy left unset is nil on both the context and the global config.
# - model_registry_file can point at a path inside the scenario folder.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module BremertonOpenrouterBase
  # The yard clerk at Bremerton Marina points the dry-dock context at
  # OpenRouter's public v1 base and keeps the registry file off the user
  # cache, beside the gate log.
  class DryDockBase
    OPENROUTER_BASE = "https://openrouter.ai/api/v1"

    INSTRUCTIONS = <<~TEXT.strip
      You are the yard clerk at Bremerton Marina, Port of Bremerton.
      Answer in one or two short sentences.
      Use only the gate schedule in the question.
      Name Cape Flattery and 09:15.
      Do not invent a flood time.
    TEXT

    SCHEDULE_QUESTION = <<~TEXT.strip
      Haul-out gate schedule posted at Bremerton Marina for Wednesday 14 October 2026.
      Port office: https://www.portofbremerton.org/.
      Gate opens 06:30.
      Dock floods 09:15 for the seiner Cape Flattery.
      Afternoon flood 15:05 for the cannery tender Retort.
      When does the dock flood for Cape Flattery?
    TEXT

    Result = Struct.new(
      :flood,
      :context_base,
      :global_base,
      :context_proxy,
      :global_proxy,
      :registry_file,
      :uri,
      keyword_init: true
    )

    def self.conduct
      configure
      registry = File.expand_path("tmp/ruby_llm_models.json", __dir__)
      yard = RubyLLM.context do |config|
        config.openrouter_api_base = OPENROUTER_BASE
        config.model_registry_file = registry
      end
      chat = open_chat(yard)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      flood = chat.ask(SCHEDULE_QUESTION)

      Result.new(
        flood: flood.content,
        context_base: yard.config.openrouter_api_base,
        global_base: RubyLLM.config.openrouter_api_base,
        context_proxy: yard.config.http_proxy,
        global_proxy: RubyLLM.config.http_proxy,
        registry_file: yard.config.model_registry_file
      )
    end

    def self.open_chat(context)
      ConfigurationPaidOpenrouter.prepare(
        context.chat(**ConfigurationPaidOpenrouter.chat_args)
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
  Multivitamin::Cassettes.play(__dir__, "dry_dock_base") do
    result = BremertonOpenrouterBase::DryDockBase.conduct
  end

  puts "base #{result.context_base} proxy #{result.context_proxy.inspect}:"
  puts result.flood
end
