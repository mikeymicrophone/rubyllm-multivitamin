# frozen_string_literal: true

# Models and providers · 04 · León sesame lote assume exists
#
# Teaches:
# - assume_model_exists: true without a provider raises ArgumentError.
# - A slug the registry lacks becomes a synthetic Model with assumed
#   capabilities and a metadata warning.
# - A slug find already knows keeps its registry entry; assume does not
#   replace it.
# - A chat with provider: :openai and assume_model_exists still asks.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LeonSesame
  # The lote clerk at a León sesame house tries to put an unlisted clerk
  # on the radio, then names the channel, then asks whether Ajonjolí Norte
  # can go to roaster 2.
  class LoteClerk
    UNLISTED = "leon-sesame-lote-unlisted"

    INSTRUCTIONS = <<~TEXT.strip
      You are the lote clerk at a sesame house in León, Nicaragua.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the roaster card in the question.
      Do not invent moisture numbers.
    TEXT

    DRYER_QUESTION = <<~TEXT.strip
      León sesame house, roaster 2, Wednesday 14 October 2026.
      House page: https://www.inta.gob.ni/
      Moisture desk: roaster 2, posted limit 12.0 percent.
      Posted moisture for lote Ajonjolí Norte at 11:40 is 11.2 percent.
      The belt is clear. The hull fans are running.
      Can Ajonjolí Norte go to roaster 2 at 11:40?
    TEXT

    Result = Struct.new(
      :missing_provider_error,
      :missing_provider_message,
      :unlisted_id,
      :unlisted_provider,
      :unlisted_capabilities,
      :unlisted_warning,
      :unlisted_function_calling,
      :unlisted_reasoning,
      :unlisted_window,
      :listed_id,
      :listed_warning,
      :listed_capabilities,
      :listed_window,
      :alongside,
      :alongside_model,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      missing_error = nil
      missing_message = nil
      begin
        RubyLLM.chat(model: UNLISTED, assume_model_exists: true)
      rescue ArgumentError => error
        missing_error = error.class.name
        missing_message = error.message
      end

      unlisted = RubyLLM.chat(
        model: UNLISTED,
        provider: :openai,
        assume_model_exists: true
      )

      listed_slug = Multivitamin::Models::OPENAI_CHAT
      listed = RubyLLM.chat(
        model: listed_slug,
        provider: :openai,
        assume_model_exists: true
      )

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      alongside = chat.ask(DRYER_QUESTION)

      Result.new(
        missing_provider_error: missing_error,
        missing_provider_message: missing_message,
        unlisted_id: unlisted.model.id,
        unlisted_provider: unlisted.model.provider,
        unlisted_capabilities: unlisted.model.capabilities,
        unlisted_warning: unlisted.model.metadata[:warning],
        unlisted_function_calling: unlisted.model.supports?(:function_calling),
        unlisted_reasoning: unlisted.model.supports?(:reasoning),
        unlisted_window: unlisted.model.context_window,
        listed_id: listed.model.id,
        listed_warning: listed.model.metadata[:warning],
        listed_capabilities: listed.model.capabilities,
        listed_window: listed.model.context_window,
        alongside: alongside.content,
        alongside_model: alongside.model,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        # Assume-exists chats name provider: :openai. The ask may go out on
        # OpenRouter when LIVE_PROVIDER=openrouter; OpenAI still has to be
        # configured so those two constructions do not raise.
        config.openai_api_key = ENV["OPENAI_API_KEY"].to_s.empty? ? Multivitamin::Cassettes::PLACEHOLDER_KEY : ENV["OPENAI_API_KEY"]
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
  Multivitamin::Cassettes.play(__dir__, "lote_clerk") do
    result = LeonSesame::LoteClerk.conduct
  end

  puts result.missing_provider_message
  puts "unlisted #{result.unlisted_id} warning=#{result.unlisted_warning}"
  puts "listed #{result.listed_id} window=#{result.listed_window}"
  puts
  puts result.alongside
end
