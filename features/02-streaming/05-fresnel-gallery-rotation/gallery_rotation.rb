# frozen_string_literal: true

# Streaming · 05 · Fresnel gallery rotation
#
# Teaches:
# - Empty chunks and reasoning-only chunks are not spoken on the gallery phone.
# - A tight with_max_output_tokens can stream reasoning and return nil content.
# - The draft of that clipped note is on thinking.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module FresnelGalleryRotation
  # The lens keeper times the fourth-order Fresnel from the gallery, then
  # tries to dictate a second timing under a cap that the reasoning fills.
  class GalleryRotation
    INSTRUCTIONS = <<~TEXT.strip
      You are the lens keeper in the gallery at Point Wilson Light Station.
      Speak one short sentence.
      Use only the timing card.
      Name the flash of 0.4 seconds and the eclipse of 9.6 seconds.
    TEXT

    TIMING_QUESTION = <<~TEXT.strip
      Lens timing card for Wednesday 14 October 2026, Point Wilson gallery.
      Fourth-order Fresnel, cabinet closed, lamp burning.
      Flash 0.4 seconds. Eclipse 9.6 seconds.
      Speak the timing for the watch phone.
    TEXT

    CLIPPED_QUESTION = <<~TEXT.strip
      The relief asks for the same Point Wilson gallery timing again.
      Flash 0.4 seconds. Eclipse 9.6 seconds. Fourth-order Fresnel.
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
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "gallery_rotation") do
    result = FresnelGalleryRotation::GalleryRotation.conduct
  end

  puts result.speech
  puts
  puts "clipped finish=#{result.clipped_finish} max_tokens=#{result.clipped_max_tokens}"
  puts result.clipped_content.inspect
end
