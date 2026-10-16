# frozen_string_literal: true

require_relative "runtime"

module Multivitamin
  # Shared transport configuration only; prompts and task policy belong to desks.
  module Research
    module_function

    def context
      RubyLLM.context do |config|
        Runtime.apply(config, provider: :vertexai, timeout: 120)
      end
    end

    def interval = Cassettes.live? ? 5 : 0.001
  end
end
