# frozen_string_literal: true

# Configuration and contexts · 04 · Svalbard seed-vault timeout
#
# Teaches:
# - request_timeout on a context is read back from that context's config.
# - RubyLLM.config.request_timeout stays at the global value.
# - ctx.chat still completes a short vault-card turn.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module SvalbardSeedTimeout
  # The seed-vault clerk at Longyearbyen waits longer than the catalog
  # default for a permafrost logger that hops the satellite, without
  # changing the global timeout the rest of the desk uses.
  class VaultTimeout
    GLOBAL_TIMEOUT = 120
    VAULT_TIMEOUT = 180

    INSTRUCTIONS = <<~TEXT.strip
      You are the seed-vault clerk at Svalbard Global Seed Vault
      outside Longyearbyen.
      Copy the logger card in two short sentences.
      Use only the card in the question.
      Include -18 and SV-180.
      Do not describe the mountain.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Logger card posted in the Svalbard seed vault, Wednesday 14 October 2026.
      Vault page: https://www.seedvault.no/.
      Chamber temperature -18 C and steady.
      Accession SV-180, Ethiopian teff, last checked 03:10.
      The satellite hop to the Oslo desk can sit for three minutes.
      Write the slate for the vault log.
    TEXT

    Result = Struct.new(
      :slate,
      :vault_timeout,
      :global_timeout,
      keyword_init: true
    )

    def self.conduct
      configure
      vault = RubyLLM.context do |config|
        config.request_timeout = VAULT_TIMEOUT
      end
      chat = open_chat(vault)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      slate = chat.ask(CARD_QUESTION)

      Result.new(
        slate: slate.content,
        vault_timeout: vault.config.request_timeout,
        global_timeout: RubyLLM.config.request_timeout
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
        config.request_timeout = GLOBAL_TIMEOUT
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "vault_timeout") do
    result = SvalbardSeedTimeout::VaultTimeout.conduct
  end

  puts "timeout #{result.vault_timeout} (global #{result.global_timeout}):"
  puts result.slate
end
