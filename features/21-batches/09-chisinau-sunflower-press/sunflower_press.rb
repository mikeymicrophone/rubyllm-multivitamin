# frozen_string_literal: true

# Batches · 09 · Chisinau sunflower-press one-model rule
#
# Teaches:
# - OpenAI batch requests must use one model per submission.
# - Mixing gpt-4.1-mini and gpt-4o-mini raises before the upload.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ChisinauSunflowerPress
  class PressModels
    Result = Struct.new(:error_class, :message, keyword_init: true)

    def self.conduct
      configure
      first = open_chat(model: Multivitamin::Models::OPENAI_CHAT)
      first.with_instructions("Name 30 presses and Ion.")
      first.ask_later("Chisinau sunflower loft. How many presses on the east line?")
      second = open_chat(model: Multivitamin::Models::OPENAI_CHAT_SWITCH)
      second.with_instructions("Name 30 presses and Ion.")
      second.ask_later("Chisinau sunflower loft. Who holds the hopper?")
      RubyLLM.batch([first, second])
    rescue RubyLLM::Error => error
      Result.new(error_class: error.class.name, message: error.message)
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

    def self.open_chat(model: nil)
      kwargs = Multivitamin::Models.chat(provider: :openai)
      kwargs = kwargs.merge(model: model) if model
      chat = RubyLLM.chat(**kwargs)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

  end
end

if $PROGRAM_NAME == __FILE__
  result = ChisinauSunflowerPress::PressModels.conduct
  puts "#{result.error_class}: #{result.message}"
end
