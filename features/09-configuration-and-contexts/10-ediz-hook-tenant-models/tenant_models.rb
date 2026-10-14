# frozen_string_literal: true

# Configuration and contexts · 10 · Ediz Hook and Port Angeles default models
#
# Teaches:
# - Each tenant context can set a different default_model.
# - ctx.chat with no model: uses that tenant's default.
# - The two cassette bodies name two different slugs.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module EdizHookTenantModels
  # The buoy tender off Ediz Hook and the loft clerk at Port Angeles each
  # get a default model. Neither chat names a slug at call time.
  class TenantModels
    HOOK_INSTRUCTIONS = <<~TEXT.strip
      You are the buoy tender working the Ediz Hook bell buoy.
      Answer in two short sentences.
      Use only the ledger in the question.
      Quote 11.8 volts.
      Do not invent a haul date.
    TEXT

    HOOK_QUESTION = <<~TEXT.strip
      Maintenance ledger for the lighted bell buoy off Ediz Hook.
      Light list: https://www.navcen.uscg.gov/.
      Last painted: 12 March 2026, red.
      Battery this morning: 11.8 volts.
      Next haul: 3 November 2026.
      What is the battery voltage, and when is the next haul?
    TEXT

    LOFT_INSTRUCTIONS = <<~TEXT.strip
      You are Hattie, the loft boss at the Port Angeles net loft.
      Answer in two short sentences.
      Use only ticket NL-214 in the question.
      Name twine 36.
      Do not mend the herring bait bag.
    TEXT

    LOFT_QUESTION = <<~TEXT.strip
      Mending ticket NL-214 for the seiner Cape Flattery.
      Tear 1: cork line, 14 meshes, starboard shoulder, twine 36.
      Tear 2: lead line, 6 meshes, belly, twine 48.
      The herring bait bag is not on this ticket.
      Which tear do you mend first, and what twine?
    TEXT

    Result = Struct.new(
      :hook_reply,
      :loft_reply,
      :hook_model_id,
      :loft_model_id,
      :hook_default,
      :loft_default,
      :global_default,
      keyword_init: true
    )

    def self.conduct
      configure
      hook_slug = hook_args.fetch(:model)
      loft_slug = loft_args.fetch(:model)

      hook = RubyLLM.context do |config|
        config.default_model = hook_slug
      end
      hook_chat = open_chat(hook, hook_args.except(:model))
      hook_chat.with_instructions(HOOK_INSTRUCTIONS)
      hook_chat.with_temperature(0.2)
      hook_reply = hook_chat.ask(HOOK_QUESTION)

      loft = RubyLLM.context do |config|
        config.default_model = loft_slug
      end
      loft_chat = open_chat(loft, loft_args.except(:model))
      loft_chat.with_instructions(LOFT_INSTRUCTIONS)
      loft_chat.with_temperature(0.2)
      loft_reply = loft_chat.ask(LOFT_QUESTION)

      Result.new(
        hook_reply: hook_reply.content,
        loft_reply: loft_reply.content,
        hook_model_id: hook_reply.model,
        loft_model_id: loft_reply.model,
        hook_default: hook.config.default_model,
        loft_default: loft.config.default_model,
        global_default: RubyLLM.config.default_model
      )
    end

    def self.hook_args
      ConfigurationPaidOpenrouter.chat_args
    end

    def self.loft_args
      ConfigurationPaidOpenrouter.spare_args
    end

    def self.open_chat(context, args)
      ConfigurationPaidOpenrouter.prepare(context.chat(**args))
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
  Multivitamin::Cassettes.play(__dir__, "tenant_models") do
    result = EdizHookTenantModels::TenantModels.conduct
  end

  puts "hook #{result.hook_model_id}:"
  puts result.hook_reply
  puts
  puts "loft #{result.loft_model_id}:"
  puts result.loft_reply
end
