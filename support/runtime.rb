# frozen_string_literal: true

require "logger"
require "ruby_llm"
require_relative "cassettes"
require_relative "models"

module Multivitamin
  # Transport defaults shared by the bottled examples. Keep lesson-specific
  # chat configuration in the scenario, where readers can see it.
  module Runtime
    REGISTRY_FILE = File.expand_path("../tmp/ruby_llm_models.json", __dir__)

    module_function

    def configure(provider:, timeout: 120)
      RubyLLM.configure { |config| apply(config, provider: provider, timeout: timeout) }
    end

    def apply(config, provider:, timeout: 120)
      Models.configure(config, provider: provider)
      config.max_retries = 0
      config.request_timeout = timeout
      config.model_registry_file = REGISTRY_FILE
      config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      config
    end
  end
end
