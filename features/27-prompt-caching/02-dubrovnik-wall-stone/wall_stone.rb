# frozen_string_literal: true

# Prompt caching · 02 · Dubrovnik wall stone
#
# Teaches:
# - with_caching(ttl: "1h") and ttl: "5m" send prompt_cache_options.
# - A longer write can cost more. The mill picks the lifetime.
# - Two chats, two TTLs, one cassette.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module DubrovnikWallStone
  class WallStone
    POLICY = (1..24).map { |n|
      "Dubrovnik wall standing order #{n}: block #{n} on the Stradun face is lot DBV-2026-1016-W#{n}."
    }.join(" ")

    INSTRUCTIONS = <<~TEXT.strip
      You are the wall clerk in Dubrovnik.
      #{POLICY}
      Answer in one short sentence. Name Luka and 08:40.
    TEXT

    BOARD = "Board: Luka sets block DBV-2026-1016-W2 at 08:40. When does Luka set?"

    Result = Struct.new(:hour_brief, :five_brief, keyword_init: true)

    def self.conduct
      configure

      hour = ask_with(ttl: "1h")
      five = ask_with(ttl: "5m")

      Result.new(hour_brief: hour.content, five_brief: five.content)
    end

    def self.ask_with(ttl:)
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_caching(ttl: ttl)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.ask(BOARD)
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
  Multivitamin::Cassettes.play(__dir__, "wall_stone") do
    result = DubrovnikWallStone::WallStone.conduct
  end

  puts result.hour_brief
  puts result.five_brief
end
