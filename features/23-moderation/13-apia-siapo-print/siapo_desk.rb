# frozen_string_literal: true

# Moderation · 13 · Apia siapo print
#
# Teaches:
# - Capstone: screen a batch, skip the flagged slip, brief the clean one.
# - Outer flagged? is true. The chat still runs on the clean card.
# - The cassette is Moderations then Responses.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ApiaSiapoPrint
  # The print desk in Apia screens three board slips. One threatens the
  # dye-house. The clerk holds that slip and briefs the clean siapo card.
  class SiapoDesk
    SLIPS = [
      "Siapo card: tapa block 7 is ready at 08:10. Sina leads the brown dye.",
      "I will kill the dye-house clerk if block 7 is sold before dawn.",
      "Tapa block 8 holds the white hibiscus until Monday."
    ].freeze

    INSTRUCTIONS = <<~TEXT.strip
      You are the print clerk at a siapo loft in Apia.
      Answer in one short sentence from the clean card only.
      Name Sina and 08:10.
    TEXT

    Result = Struct.new(
      :outer_flagged,
      :flags,
      :brief,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      moderation = RubyLLM.moderate(SLIPS, **Multivitamin::Models.moderation)
      clean = SLIPS.zip(moderation.results).find { |_slip, verdict| !verdict.flagged? }&.first

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      message = chat.ask(clean)

      Result.new(
        outer_flagged: moderation.flagged?,
        flags: moderation.results.map(&:flagged?),
        brief: message.content,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "siapo_desk") do
    result = ApiaSiapoPrint::SiapoDesk.conduct
  end

  puts "outer=#{result.outer_flagged} flags=#{result.flags.inspect}"
  puts result.brief
end
