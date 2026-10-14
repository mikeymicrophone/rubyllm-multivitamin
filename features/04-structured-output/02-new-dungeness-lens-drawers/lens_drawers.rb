# frozen_string_literal: true

# Structured output · 02 · New Dungeness lens drawers
#
# Teaches:
# - An array field holds one object per drawer.
# - Nested object fields are required unless marked otherwise.
# - The parsed value of the array is an Array of Hashes.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NewDungenessLensDrawers
  class LensCabinet < Schematist::Schema
    title "lens_cabinet"
    description "Drawer inventory for the fourth-order lens at New Dungeness"

    array :drawers, description: "One entry for each drawer named on the card" do
      object do
        string :drawer, description: "Drawer letter on the cabinet"
        string :contents, description: "What the card says is in that drawer"
        integer :spares, description: "Spare count written on the card"
      end
    end
  end

  class DrawerInventory
    INSTRUCTIONS = <<~TEXT.strip
      You are the lens keeper at New Dungeness Light.
      Fill lens_cabinet with one object per drawer on the card.
      Copy the contents and the spare counts. Keep the drawer letters.
    TEXT

    CARD = <<~TEXT.strip
      New Dungeness lens cabinet, Wednesday 14 October 2026.
      Station notes: https://newdungenesslighthouse.com/
      Drawer A: bull's-eye panel, 2 spares.
      Drawer B: catadioptric prism, 1 spare.
      Drawer C: clockwork wick, 6 spares.
    TEXT

    Result = Struct.new(:parsed, :roles, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(LensCabinet)

      answer = chat.ask(CARD)

      Result.new(
        parsed: answer.parsed,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "lens_drawers") do
    result = NewDungenessLensDrawers::DrawerInventory.conduct
  end

  puts JSON.generate(result.parsed)
end
