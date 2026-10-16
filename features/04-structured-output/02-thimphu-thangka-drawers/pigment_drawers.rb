# frozen_string_literal: true

# Structured output · 02 · Thimphu thangka pigment drawers
#
# Teaches:
# - An array field holds one object per drawer.
# - Nested object fields are required unless marked otherwise.
# - The parsed value of the array is an Array of Hashes.
# - Data records and a find pattern identify the drawer with its last spare.

require "json"
require_relative "../../../support/runtime"

module ThimphuThangkaDrawers
  class PigmentCabinet < Schematist::Schema
    title "pigment_cabinet"
    description "Drawer inventory for the mineral pigments at the Thimphu thangka atelier"

    array :drawers, description: "One entry for each drawer named on the card" do
      object do
        string :drawer, description: "Drawer letter on the cabinet"
        string :contents, description: "What the card says is in that drawer"
        integer :spares, description: "Spare count written on the card"
      end
    end
  end

  class DrawerInventory
    Drawer = Data.define(:letter, :contents, :spares)

    INSTRUCTIONS = <<~TEXT.strip
      You are the pigment keeper at the thangka atelier in Thimphu.
      Fill pigment_cabinet with one object per drawer on the card.
      Copy the contents and the spare counts. Keep the drawer letters.
    TEXT

    CARD = <<~TEXT.strip
      Thimphu thangka pigment cabinet, Wednesday 14 October 2026.
      Atelier notes: https://www.bhutan.travel/
      Drawer A: malachite green, 2 spares.
      Drawer B: cinnabar, 1 spare.
      Drawer C: gold leaf, 6 spares.
    TEXT

    Result = Data.define(:parsed, :roles, :finish, :input_tokens, :cost, :last_spare)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_schema(PigmentCabinet)

      answer = chat.ask(CARD)
      drawers = answer.parsed.fetch("drawers").map do |entry|
        case entry.transform_keys(&:to_sym)
        in { drawer: String => letter, contents: String => contents, spares: Integer => spares }
          Drawer.new(letter: letter, contents: contents, spares: spares)
        else
          raise ArgumentError, "Incomplete pigment drawer: #{entry.inspect}"
        end
      end
      last_spare = case drawers
                   in [*, Drawer[spares: 1] => drawer, *]
                     drawer.letter
                   else
                     nil
                   end

      Result.new(
        parsed: answer.parsed,
        roles: chat.messages.map(&:role),
        finish: answer.finish_reason,
        input_tokens: answer.tokens.input,
        cost: answer.cost.total,
        last_spare: last_spare
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "pigment_drawers") do
    ThimphuThangkaDrawers::DrawerInventory.conduct
  end

  puts JSON.generate(result.parsed)
end
