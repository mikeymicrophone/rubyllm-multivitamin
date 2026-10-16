# frozen_string_literal: true

# Configuration and contexts · 08 · Limoges enamel OpenRouter base URL
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

module LimogesEnamelBase
  # The enamel studio on rue du Consulat points the kiln context at
  # OpenRouter's public v1 base and keeps the registry file off the user
  # cache, beside the firing board.
  class EnamelBase
    OPENROUTER_BASE = "https://openrouter.ai/api/v1"

    INSTRUCTIONS = <<~TEXT.strip
      You are the kiln clerk at the enamel studio on rue du Consulat, Limoges.
      Answer in one or two short sentences.
      Use only the firing board in the question.
      The reply must include the words Sainte-Valerie and the time 09:15.
      Do not invent a soak time.
    TEXT

    SCHEDULE_QUESTION = <<~TEXT.strip
      Firing board posted at the Limoges enamel studio for Wednesday 14 October 2026.
      City page: https://www.limoges.fr/.
      Kiln door opens 06:30.
      First soak 09:15 for the Sainte-Valerie plaque.
      Afternoon soak 15:05 for the civic arms dish.
      When does the kiln soak for Sainte-Valerie?
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
      studio = RubyLLM.context do |config|
        config.openrouter_api_base = OPENROUTER_BASE
        config.model_registry_file = registry
      end
      chat = open_chat(studio)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      flood = chat.ask(SCHEDULE_QUESTION)

      Result.new(
        flood: flood.content,
        context_base: studio.config.openrouter_api_base,
        global_base: RubyLLM.config.openrouter_api_base,
        context_proxy: studio.config.http_proxy,
        global_proxy: RubyLLM.config.http_proxy,
        registry_file: studio.config.model_registry_file
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
  Multivitamin::Cassettes.play(__dir__, "enamel_base") do
    result = LimogesEnamelBase::EnamelBase.conduct
  end

  puts "base #{result.context_base} proxy #{result.context_proxy.inspect}:"
  puts result.flood
end
