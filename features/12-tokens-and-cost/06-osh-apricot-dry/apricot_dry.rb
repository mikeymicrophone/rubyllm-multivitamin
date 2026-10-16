# frozen_string_literal: true

# Tokens and cost · 06 · Osh apricot-dry cache and thinking
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

module OshApricotDry
  # The dry-yard clerk at Osh copies the moisture card for the truck
  # Ala-Too, and reads cache and thinking buckets off the reply.
  class ApricotDry
    INSTRUCTIONS = <<~TEXT.strip
      You are the dry-yard clerk at the apricot yards outside Osh.
      Answer in two short sentences.
      Use only the moisture card in the question.
      Name 5.2 percent and the truck Ala-Too.
      Do not invent a loading time.
    TEXT

    CARD_QUESTION = <<~TEXT.strip
      Osh apricot-dry card, Friday 16 October 2026, 08:10.
      Market notes: https://www.stat.kg/
      Road board: https://www.mintrans.kg/
      Moisture 5.2 percent on the south racks, still too wet for the Jalal-Abad run.
      The 08:20 Ala-Too truck from the Kara-Suu road is held until the fruit drops under 4.0 percent.
      Loading window 10:35.
      Should the clerk hold Ala-Too, and what is the moisture?
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
      brief = chat.ask(CARD_QUESTION)

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
  Multivitamin::Cassettes.play(__dir__, "apricot_dry") do
    result = OshApricotDry::ApricotDry.conduct
  end

  puts result.brief
  puts "cache_read=#{result.cache_read.inspect} cache_write=#{result.cache_write.inspect} " \
       "thinking=#{result.thinking_tokens.inspect}"
end
