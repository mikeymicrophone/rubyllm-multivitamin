# frozen_string_literal: true

# Streaming · 05 · Paranal shutter timing
#
# Teaches:
# - Empty chunks and reasoning-only chunks are not spoken on the control phone.
# - A tight with_max_output_tokens can stream reasoning and return nil content.
# - The draft of that clipped note is on thinking.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module ParanalShutterTiming
  # The night astronomer times the UT1 Nasmyth shutter, then tries to
  # dictate a second timing under a cap that the reasoning fills.
  class ShutterTiming
    INSTRUCTIONS = <<~TEXT.strip
      You are the night astronomer at Cerro Paranal in the Atacama.
      Speak one short sentence.
      Use only the timing card.
      Name the open of 0.4 seconds and the closed of 9.6 seconds.
    TEXT

    TIMING_QUESTION = <<~TEXT.strip
      Shutter timing card for Wednesday 14 October 2026, UT1 Nasmyth at Cerro Paranal.
      Observatory notes: https://www.eso.org/public/teles-instr/paranal-observatory/vlt/
      UT1 Nasmyth, enclosure closed, lamp burning on the guide probe.
      Open 0.4 seconds. Closed 9.6 seconds.
      Speak the timing for the control phone.
    TEXT

    CLIPPED_QUESTION = <<~TEXT.strip
      The relief asks for the same Paranal UT1 Nasmyth timing again.
      Open 0.4 seconds. Closed 9.6 seconds. UT1 Nasmyth.
      Speak it in two sentences.
    TEXT

    CLIP = 64

    Result = Struct.new(
      :speech,
      :thinking,
      :spoken_pieces,
      :reasoning_chunks,
      :empty_chunks,
      :clipped_content,
      :clipped_thinking,
      :clipped_finish,
      :clipped_max_tokens,
      :clipped_reasoning_chunks,
      :clipped_spoken_pieces,
      keyword_init: true
    )

    def self.conduct
      configure

      spoken = stream(TIMING_QUESTION, cap: nil)
      clipped = stream(CLIPPED_QUESTION, cap: CLIP)

      Result.new(
        speech: spoken[:message].content,
        thinking: spoken[:message].thinking&.text,
        spoken_pieces: spoken[:spoken],
        reasoning_chunks: spoken[:reasoning],
        empty_chunks: spoken[:empty],
        clipped_content: clipped[:message].content,
        clipped_thinking: clipped[:message].thinking&.text,
        clipped_finish: clipped[:message].finish_reason,
        clipped_max_tokens: clipped[:message].max_tokens?,
        clipped_reasoning_chunks: clipped[:reasoning],
        clipped_spoken_pieces: clipped[:spoken]
      )
    end

    def self.stream(question, cap:)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_max_output_tokens(cap) if cap

      spoken = []
      reasoning = 0
      empty = 0
      message = chat.ask(question) do |chunk|
        piece = chunk.content.to_s
        if piece.empty?
          empty += 1
          reasoning += 1 if chunk.thinking&.text
        else
          spoken << piece
        end
      end

      { message: message, spoken: spoken, reasoning: reasoning, empty: empty }
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "shutter_timing") do
    result = ParanalShutterTiming::ShutterTiming.conduct
  end

  puts result.speech
  puts
  puts "clipped finish=#{result.clipped_finish} max_tokens=#{result.clipped_max_tokens}"
  puts result.clipped_content.inspect
end
