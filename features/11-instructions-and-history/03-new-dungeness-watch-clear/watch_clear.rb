# frozen_string_literal: true

# Instructions and history · 03 · New Dungeness watch clears instructions
#
# Teaches:
# - with_instructions(nil) drops every :system message.
# - User and assistant turns stay on the chat.
# - The next request has no instructions field.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NewDungenessWatchClear
  # The lens keeper at New Dungeness answers from the cabinet list under
  # standing orders, then clears those orders when the watch changes and
  # asks about the chimneys from history alone.
  class WatchClear
    INSTRUCTIONS = <<~TEXT.strip
      You are the lens keeper at New Dungeness Light Station on the Dungeness Spit.
      These are the lens-room standing orders.
      Answer in two short sentences.
      Quote catalog marks exactly as printed.
      Do not invent drawers.
    TEXT

    CABINET_QUESTION = <<~TEXT.strip
      Cabinet list posted in the lens room at New Dungeness Light.
      Station log: https://newdungenesslighthouse.com/
      Drawer B: spare bull's-eye, catalog NB-17.
      Drawer C: six lamp chimneys, catalog LC-6.
      Drawer F: clockwork oil cup, catalog OC-9, dry.
      Which drawer holds the spare bull's-eye, and what is its catalog mark?
    TEXT

    CHIMNEY_QUESTION = "The relief watch is on. How many chimneys are in drawer C? Quote the catalog mark."

    Result = Struct.new(
      :cabinet,
      :chimneys,
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
      chimneys = chat.ask(CHIMNEY_QUESTION)

      Result.new(
        cabinet: cabinet.content,
        chimneys: chimneys.content,
        roles_before_clear: roles_before_clear,
        roles_after_clear: roles_after_clear,
        roles: chat.messages.map(&:role),
        finish: chimneys.finish_reason
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
  Multivitamin::Cassettes.play(__dir__, "watch_clear") do
    result = NewDungenessWatchClear::WatchClear.conduct
  end

  puts result.cabinet
  puts
  puts result.chimneys
end
