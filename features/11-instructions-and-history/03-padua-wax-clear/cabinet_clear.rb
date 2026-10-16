# frozen_string_literal: true

# Instructions and history · 03 · Padua wax cabinet clears instructions
#
# Teaches:
# - with_instructions(nil) drops every :system message.
# - User and assistant turns stay on the chat.
# - The next request has no instructions field.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PaduaWaxClear
  # The cabinet clerk at the University of Padua wax rooms answers from
  # the drawer list under standing orders, then clears those orders when
  # the tutorial changes and asks about the vitrine lamps from history alone.
  class CabinetClear
    INSTRUCTIONS = <<~TEXT.strip
      You are the cabinet clerk at the University of Padua wax rooms.
      These are the wax-room standing orders.
      Answer in two short sentences.
      Quote catalog marks exactly as printed.
      Do not invent drawers.
    TEXT

    CABINET_QUESTION = <<~TEXT.strip
      Cabinet list posted in the wax rooms at Palazzo Bo, Padua.
      Museum page: https://www.unipd.it/
      Drawer B: spare wax hand, catalog NB-17.
      Drawer C: six vitrine lamps, catalog LC-6.
      Drawer F: beeswax cake, catalog OC-9, dry.
      Which drawer holds the spare wax hand, and what is its catalog mark?
    TEXT

    LAMP_QUESTION = "The afternoon tutorial is on. How many vitrine lamps are in drawer C? Quote the catalog mark."

    Result = Struct.new(
      :cabinet,
      :lamps,
      :roles_before_clear,
      :roles_after_clear,
      :roles,
      :finish,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      cabinet = chat.ask(CABINET_QUESTION)
      roles_before_clear = chat.messages.map(&:role)

      chat.with_instructions(nil)
      roles_after_clear = chat.messages.map(&:role)
      lamps = chat.ask(LAMP_QUESTION)

      Result.new(
        cabinet: cabinet.content,
        lamps: lamps.content,
        roles_before_clear: roles_before_clear,
        roles_after_clear: roles_after_clear,
        roles: chat.messages.map(&:role),
        finish: lamps.finish_reason
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
  Multivitamin::Cassettes.play(__dir__, "cabinet_clear") do
    result = PaduaWaxClear::CabinetClear.conduct
  end

  puts result.cabinet
  puts
  puts result.lamps
end
