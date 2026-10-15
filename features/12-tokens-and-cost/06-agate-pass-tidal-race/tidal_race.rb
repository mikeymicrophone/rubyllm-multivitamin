# frozen_string_literal: true

# Tokens and cost · 06 · Agate Pass tidal-race cache and thinking
#
# Teaches:
# - tokens.cache_read and tokens.cache_write are whatever the provider
#   reported, including 0, or nil when the field is omitted.
# - tokens.thinking holds reasoning tokens when the slug reports them.
# - with_caching asks for a cache. A first pass can still report no hits.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AgatePassTidalRace
  # The current clerk at Agate Pass copies the Suquamish race for the
  # ferry Kitsap, and reads cache and thinking buckets off the reply.
  class TidalRace
    INSTRUCTIONS = <<~TEXT.strip
      You are the current clerk at Agate Pass, between Bainbridge Island and the Kitsap shore.
      Answer in two short sentences.
      Use only the race card in the question.
      Name 5.2 knots and the ferry Kitsap.
      Do not invent a slack.
    TEXT

    RACE_QUESTION = <<~TEXT.strip
      Agate Pass tidal-race card, Wednesday 14 October 2026, 08:10.
      Tide reference: https://tidesandcurrents.noaa.gov/
      WSF page: https://wsdot.wa.gov/ferries
      Ebb 5.2 knots at the Agate Pass Bridge, setting north toward Port Madison.
      The 08:20 Kitsap sailing from Suquamish is held until the race drops under 4.0 knots.
      Slack before flood 10:35.
      Should the clerk hold Kitsap, and what is the ebb?
    TEXT

    Result = Struct.new(
      :brief,
      :cache_read,
      :cache_write,
      :thinking_tokens,
      :input_tokens,
      :output_tokens,
      :cache_read_nil,
      :cache_write_nil,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_caching(ttl: "5m")
      brief = chat.ask(RACE_QUESTION)

      Result.new(
        brief: brief.content,
        cache_read: brief.tokens.cache_read,
        cache_write: brief.tokens.cache_write,
        thinking_tokens: brief.tokens.thinking,
        input_tokens: brief.tokens.input,
        output_tokens: brief.tokens.output,
        cache_read_nil: brief.tokens.cache_read.nil?,
        cache_write_nil: brief.tokens.cache_write.nil?
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
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
  Multivitamin::Cassettes.play(__dir__, "tidal_race") do
    result = AgatePassTidalRace::TidalRace.conduct
  end

  puts result.brief
  puts "cache_read=#{result.cache_read.inspect} cache_write=#{result.cache_write.inspect} " \
       "thinking=#{result.thinking_tokens.inspect}"
end
