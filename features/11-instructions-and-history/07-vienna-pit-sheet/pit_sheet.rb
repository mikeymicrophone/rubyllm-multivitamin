# frozen_string_literal: true

# Instructions and history · 07 · Vienna pit-part sheet
#
# Teaches:
# - The system message stays short.
# - The user message carries the long folder sheet.
# - The answer still names the one assigned folder.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ViennaPitSheet
  # The pit librarian at the Vienna State Opera keeps a two-line
  # instruction and pastes the whole overnight folder sheet as the user turn.
  class PitSheet
    INSTRUCTIONS = <<~TEXT.strip
      You are the pit librarian at the Vienna State Opera.
      Answer in one sentence. Name the folder number.
    TEXT

    SHEET_QUESTION = <<~TEXT.strip
      Overnight pit-part sheet, Vienna State Opera, Wednesday 14 October 2026.
      House page: https://www.wiener-staatsoper.at/
      The sheet is the only assignment log for the clarinet desks.

      Folder 2, 36 pages, reserved for the house clarinet, bound and stamped.
      Folder 5, 42 pages, empty, spine split at the second gathering, do not assign.
      Folder 8, 48 pages, held for the guest oboe until 16:00, then open.
      Folder 11, 40 pages, occupied by the bassoon principal, bound only, no stamp.
      Folder 14, 54 pages, assigned to the Stadler basset-clarinet part, bound and stamped,
      outbound 05:40 for the morning Sitzprobe.
      Folder 17, 38 pages, empty, last used by the piccolo, needs a new tape strip.
      Folder 19, 60 pages, reserved for the Staatsoper layover if the evening
      run is cancelled; do not assign a guest book.
      Folder 21, 32 pages, occupied by the continuo cello, no stamp.
      Folder 24, 45 pages, empty, awaiting the guest clarinet after the
      Graz concert, not before 14:00.
      Folder 27, 50 pages, occupied by the Wagner tuba book, overnight only.

      Which folder is assigned to the Stadler basset-clarinet part?
    TEXT

    Result = Struct.new(
      :assignment,
      :system_length,
      :user_length,
      :roles,
      :finish,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      assignment = chat.ask(SHEET_QUESTION)
      system_message = chat.messages.find { |message| message.role == :system }
      user_message = chat.messages.find { |message| message.role == :user }

      Result.new(
        assignment: assignment.content,
        system_length: system_message.content.length,
        user_length: user_message.content.length,
        roles: chat.messages.map(&:role),
        finish: assignment.finish_reason
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
  Multivitamin::Cassettes.play(__dir__, "pit_sheet") do
    result = ViennaPitSheet::PitSheet.conduct
  end

  puts result.assignment
end
