# frozen_string_literal: true

# Models and providers · 06 · Everett jetty vision filter
#
# Teaches:
# - by_provider plus select { |model| model.supports?(:vision) } keeps
#   only models that can read an image.
# - Chat models on the same provider that lack vision are left on the dock.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module EverettJetty
  # The jetty keeper at the Everett waterfront filters the OpenAI clerks
  # who can read an aerial of the Snohomish mudflat channel, the way the
  # watch only hands the photograph to a clerk who can see.
  class VisionFilter
    Result = Struct.new(
      :openai_chat_count,
      :vision_count,
      :blind_count,
      :all_vision_support,
      :sample_id,
      :sample_provider,
      :sample_vision,
      keyword_init: true
    )

    def self.conduct
      configure

      openai_chats = RubyLLM.models.by_provider(:openai).chat_models
      vision = openai_chats.select { |model| model.supports?(:vision) }
      blind = openai_chats.reject { |model| model.supports?(:vision) }
      sample = vision.find { |model| model.id == "gpt-4.1-mini" } || vision.first

      Result.new(
        openai_chat_count: openai_chats.count,
        vision_count: vision.count,
        blind_count: blind.count,
        all_vision_support: vision.all? { |model| model.supports?(:vision) },
        sample_id: sample&.id,
        sample_provider: sample&.provider,
        sample_vision: sample&.supports?(:vision)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "jetty_vision") do
    result = EverettJetty::VisionFilter.conduct
  end

  puts "#{result.vision_count} OpenAI vision clerks, #{result.blind_count} left on the dock"
  puts "#{result.sample_id} vision=#{result.sample_vision}"
end
