# frozen_string_literal: true

# Batches · 11 · Ohrid pearl-nacre poll job
#
# Teaches:
# - refresh re-fetches status. It does not loop by itself.
# - A job that polls should call refresh once per tick.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module OhridPearlNacre
  class NacreJob
    INSTRUCTIONS = <<~TEXT.strip
      You are the nacre clerk at the pearl loft in Ohrid.
      Answer in one short sentence from the card only.
      Name 21 blanks and Zlata.
    TEXT

    CARD = <<~TEXT.strip
      Ohrid pearl loft card, Friday 16 October 2026.
      21 nacre blanks on the west tray. Zlata cuts the next disc.
      How many blanks, and who cuts the disc?
    TEXT

    Result = Struct.new(:before, :after, :complete, :id, keyword_init: true)

    def self.conduct
      configure
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.ask_later(CARD)
      batch = RubyLLM.batch([chat])
      before = batch.status
      batch.refresh
      Result.new(before: before, after: batch.status, complete: batch.complete?, id: batch.id)
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
  result = nil
  Multivitamin::Cassettes.play(__dir__, "pearl_nacre") do
    result = OhridPearlNacre::NacreJob.conduct
  end
  puts "before=#{result.before} after=#{result.after} complete=#{result.complete}"
end
