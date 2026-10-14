# frozen_string_literal: true

# Models and providers · 04 · Commencement Bay grain elevator assume exists
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

module CommencementBayGrain
  # The grain clerk at the Port of Tacoma elevator on Commencement Bay
  # tries to put an unlisted clerk on the radio, then names the channel,
  # then asks whether Magnolia Stem can come alongside berth 3.
  class AssumeClerk
    UNLISTED = "commencement-bay-grain-clerk-unlisted"

    INSTRUCTIONS = <<~TEXT.strip
      You are the grain clerk at the Port of Tacoma elevator on Commencement Bay.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the berth card in the question.
      Do not invent depths.
    TEXT

    BERTH_QUESTION = <<~TEXT.strip
      Commencement Bay grain elevator, berth 3, Wednesday 14 October 2026.
      Port page: https://www.portoftacoma.com/
      Tide reference: https://tidesandcurrents.noaa.gov/ station 9446484.
      Posted alongside depth at 11:40 is 34.0 ft.
      Bulk carrier Magnolia Stem drafts 32.0 ft even keel.
      The conveyor is clear. The dust fans are running.
      Can Magnolia Stem come alongside berth 3 at 11:40?
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
      alongside = chat.ask(BERTH_QUESTION)

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
  Multivitamin::Cassettes.play(__dir__, "assume_clerk") do
    result = CommencementBayGrain::AssumeClerk.conduct
  end

  puts result.missing_provider_message
  puts "unlisted #{result.unlisted_id} warning=#{result.unlisted_warning}"
  puts "listed #{result.listed_id} window=#{result.listed_window}"
  puts
  puts result.alongside
end
