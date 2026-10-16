# frozen_string_literal: true

# Instructions and history · 12 · Kanazawa gold-leaf log compacted
#
# Teaches:
# - A long overnight log can be summarized on the same chat.
# - messages= keeps four turns: system, first notice, summary question,
#   and the summary.
# - The next request drops the middle notices.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module KanazawaGoldCompact
  # The loft clerk in Higashi Chaya logs three overnight notices, asks
  # for a two-sentence handover, then keeps only four turns before the
  # relief asks about lot DH.
  class LeafCompact
    INSTRUCTIONS = <<~TEXT.strip
      You are the loft clerk beating gold leaf in Higashi Chaya, Kanazawa.
      Answer in two short sentences.
      Use only the notices that are still in this chat.
      Do not invent a millimetre.
    TEXT

    DH_NOTICE = <<~TEXT.strip
      Overnight notice 1, Wednesday 14 October 2026.
      Workshop page: https://www.kanazawa-kanko.jp/
      Daruma-haku lot DH is moved 300 mm northwest of the drying-rack mark
      printed on the loft board.
      Record the DH move.
    TEXT

    HUMIDITY_NOTICE = <<~TEXT.strip
      Overnight notice 2.
      Higashi Chaya humidity is 2 percent over the posted band. The humidifier is running.
      Record the humidity.
    TEXT

    BENCH_NOTICE = <<~TEXT.strip
      Overnight notice 3.
      The burnishing-bench sector is unchanged. The agate still covers
      the board as printed. Record the sector.
    TEXT

    SUMMARY_QUESTION = "Write a two-sentence handover of every notice still in this chat."

    RELIEF_QUESTION = "The relief asks whether DH is still on the printed mark."

    Result = Struct.new(
      :dh,
      :humidity,
      :bench,
      :summary,
      :relief,
      :roles_before_compact,
      :roles_after_compact,
      :roles,
      :kept_count,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      dh = chat.ask(DH_NOTICE)
      humidity = chat.ask(HUMIDITY_NOTICE)
      bench = chat.ask(BENCH_NOTICE)
      summary = chat.ask(SUMMARY_QUESTION)
      roles_before_compact = chat.messages.map(&:role)

      system = chat.messages.first
      opening_user = chat.messages[1]
      summary_user = chat.messages[-2]
      summary_assistant = chat.messages[-1]
      chat.messages = [system, opening_user, summary_user, summary_assistant]
      roles_after_compact = chat.messages.map(&:role)
      kept_count = chat.messages.length
      relief = chat.ask(RELIEF_QUESTION)

      Result.new(
        dh: dh.content,
        humidity: humidity.content,
        bench: bench.content,
        summary: summary.content,
        relief: relief.content,
        roles_before_compact: roles_before_compact,
        roles_after_compact: roles_after_compact,
        roles: chat.messages.map(&:role),
        kept_count: kept_count
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "leaf_compact") do
    result = KanazawaGoldCompact::LeafCompact.conduct
  end

  puts result.summary
  puts
  puts result.relief
end
