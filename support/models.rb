# frozen_string_literal: true

module Multivitamin
  # Free OpenRouter slugs checked against https://openrouter.ai/api/v1/models
  # on 14 October 2026. These are infrastructure, not scenario copy: a
  # quirked branch can reskin names inside feature folders and leave this
  # file alone.
  #
  # Free slugs move faster than RubyLLM's bundled registry. Pass
  # provider: :openrouter and assume_model_exists: true when you chat with
  # one. Fallbacks for each feature are written up in that feature's README
  # and in the root README.
  module Models
    CHAT = "nvidia/nemotron-3-super-120b-a12b:free"
    CHAT_FALLBACK = "liquid/lfm-2.5-2.6b:free"

    STRUCTURED = "nvidia/nemotron-3-super-120b-a12b:free"
    STRUCTURED_FALLBACK = "liquid/lfm-2.5-2.6b:free"

    VISION = "google/gemma-4-31b-it:free"
    AUDIO = "thinkingmachines/inkling:free"
    VIDEO_INPUT = "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free"

    EMBEDDING = "nvidia/llama-nemotron-embed-vl-1b-v2:free"
    EMBEDDING_TEXT = "nvidia/nemotron-3-embed-1b:free"

    # No :free image model was listed that day. This one is paid.
    IMAGE = "google/gemini-2.5-flash-image"
  end
end
