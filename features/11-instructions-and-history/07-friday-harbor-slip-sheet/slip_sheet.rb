# frozen_string_literal: true

# Instructions and history · 07 · Friday Harbor long slip sheet
#
# Teaches:
# - The system message stays short.
# - The user message carries the long berth sheet.
# - The answer still names the one assigned slip.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FridayHarborSlipSheet
  # The marina clerk at Friday Harbor keeps a two-line instruction and
  # pastes the whole overnight slip sheet as the user turn.
  class SlipSheet
    INSTRUCTIONS = <<~TEXT.strip
      You are the marina clerk at the Port of Friday Harbor.
      Answer in one sentence. Name the slip number.
    TEXT

    SHEET_QUESTION = <<~TEXT.strip
      Overnight slip sheet, Port of Friday Harbor, Wednesday 14 October 2026.
      Harbor office: https://www.portfridayharbor.org/
      Tide staff: https://tidesandcurrents.noaa.gov/ station 9449880.
      The sheet is the only assignment log for the inner basin.

      Slip 2, 36 ft, reserved for the county work skiff Kelp Cutter, power and water on.
      Slip 5, 42 ft, empty, fender pile split at the second wale, do not assign.
      Slip 8, 48 ft, held for the mail boat San Juan Packet until 16:00, then open.
      Slip 11, 40 ft, occupied by the gillnetter Ruby Point, power only, no water.
      Slip 14, 54 ft, assigned to the seiner Cape Flattery, power and water on,
      outbound 05:40 for the Rosario grounds.
      Slip 17, 38 ft, empty, last used by the tender Retort, needs a hose bib washer.
      Slip 19, 60 ft, reserved for the state ferry layover if the Friday Harbor
      run is cancelled; do not assign a fishing boat.
      Slip 21, 32 ft, occupied by the rowing gig Spieden, no power.
      Slip 24, 45 ft, empty, awaiting the cannery tender Retort after the
      Anacortes cook, not before 14:00.
      Slip 27, 50 ft, occupied by the whale-watch Kestrel, overnight only.

      Which slip is assigned to Cape Flattery?
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
  Multivitamin::Cassettes.play(__dir__, "slip_sheet") do
    result = FridayHarborSlipSheet::SlipSheet.conduct
  end

  puts result.assignment
end
