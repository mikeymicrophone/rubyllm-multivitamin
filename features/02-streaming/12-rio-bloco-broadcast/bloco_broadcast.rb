# frozen_string_literal: true

# Streaming · 12 · Rio Carnival bloco broadcast
#
# Teaches:
# - Each spoken chunk can be broadcast to every school that subscribed.
# - The shape is the one a later Rails integration can wrap. This folder
#   stays on plain Ruby.
# - Empty chunks are not broadcast. Each school's tape matches the message.

require_relative "../../../support/runtime"

module RioBlocoBroadcast
  # The carnival desk in the Cidade do Samba reads a rain hold for the
  # Sambadrome. Mangueira and Portela are both listening.
  class BlocoChannel
    def initialize
      @subscriptions = []
    end

    def subscribe(school, &listener)
      @subscriptions << [school, listener]
      self
    end

    def broadcast(piece)
      @subscriptions.each { |school, listener| listener.call(school, piece) }
    end
  end

  class RainBroadcast
    INSTRUCTIONS = <<~TEXT.strip
      You are the carnival desk at the Cidade do Samba in Rio de Janeiro, speaking to the escolas listening in.
      Speak the warning in two short sentences.
      Name Sambódromo, the rain of 45 millimetres, and the porta-bandeira Lívia.
      Use only the warning in the question.
    TEXT

    WARNING_QUESTION = <<~TEXT.strip
      Broadcast Wednesday 14 October 2026 from the Cidade do Samba to the escolas on the Sambódromo.
      Parade office: https://www.liesa.rio/
      Rain hold. Southeast rain 35 millimetres, gusts to 45 millimetres, through 18:00.
      The porta-bandeira Lívia is alongside the Portela float and should hold.
      Small alas stay off the west side of the avenue.
      Speak the broadcast.
    TEXT

    Result = Struct.new(:speech, :pieces, :tapes, :broadcasts, keyword_init: true)

    def self.conduct
      configure

      tapes = Hash.new { |heard, school| heard[school] = +"" }
      channel = BlocoChannel.new
      channel.subscribe("Mangueira") { |_school, piece| tapes["Mangueira"] << piece }
      channel.subscribe("Portela") { |_school, piece| tapes["Portela"] << piece }

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)

      pieces = []
      broadcasts = 0
      message = chat.ask(WARNING_QUESTION) do |chunk|
        piece = chunk.content.to_s
        next if piece.empty?

        pieces << piece
        broadcasts += 1
        channel.broadcast(piece)
      end

      Result.new(speech: message.content, pieces: pieces, tapes: tapes, broadcasts: broadcasts)
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure = Multivitamin::Runtime.configure(provider: :openai, timeout: 180)
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "bloco_broadcast") do
    RioBlocoBroadcast::RainBroadcast.conduct
  end

  puts result.speech
end
