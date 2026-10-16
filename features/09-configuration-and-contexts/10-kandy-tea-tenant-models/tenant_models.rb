# frozen_string_literal: true

# Configuration and contexts · 10 · Kandy tea loft and factory lab
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

module KandyTeaTenantModels
  # The withering loft above Kandy and the factory lab each get a
  # default model. Neither chat names a slug at call time.
  class TenantModels
    LOFT_INSTRUCTIONS = <<~TEXT.strip
      You are the withering clerk in the tea loft above Kandy.
      Answer in two short sentences.
      Use only the ledger in the question.
      Quote 11.8 kilograms.
      Do not invent a wither date.
    TEXT

    LOFT_QUESTION = <<~TEXT.strip
      Withering ledger for the loft above the Kandy factory.
      Institute page: https://www.tri.lk/.
      Last turned: 12 March 2026, orange pekoe leaf.
      Leaf on the tats this morning: 11.8 kilograms.
      Next wither: 3 November 2026.
      What is the leaf weight, and when is the next wither?
    TEXT

    LAB_INSTRUCTIONS = <<~TEXT.strip
      You are Nimal, the tasting clerk at the Kandy factory lab.
      Answer in two short sentences.
      Use only ticket TF-214 in the question.
      Name theaflavin 36.
      Do not taste the broken pekoe dust.
    TEXT

    LAB_QUESTION = <<~TEXT.strip
      Tasting ticket TF-214 for the Kandy factory lab.
      Cup 1: orange pekoe, liquor bright, theaflavin 36.
      Cup 2: broken pekoe, dull, theaflavin 22.
      The dust grade is not on this ticket.
      Which cup do you taste first, and what theaflavin?
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
      hook_chat.with_instructions(LOFT_INSTRUCTIONS)
      hook_chat.with_temperature(0.2)
      hook_reply = hook_chat.ask(LOFT_QUESTION)

      loft = RubyLLM.context do |config|
        config.default_model = loft_slug
      end
      loft_chat = open_chat(loft, loft_args.except(:model))
      loft_chat.with_instructions(LAB_INSTRUCTIONS)
      loft_chat.with_temperature(0.2)
      loft_reply = loft_chat.ask(LAB_QUESTION)

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
        # Leave the catalog default in place so a previous example's
        # default_model does not leak into this tenant comparison.
        config.default_model = "gpt-5.6"
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
    result = KandyTeaTenantModels::TenantModels.conduct
  end

  puts "loft #{result.hook_model_id}:"
  puts result.hook_reply
  puts
  puts "lab #{result.loft_model_id}:"
  puts result.loft_reply
end
