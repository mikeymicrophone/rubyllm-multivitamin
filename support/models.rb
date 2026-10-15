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

    # OpenAI embedding model. text-embedding-3-small is 1536 dimensions
    # and accepts dimensions:. Confirmed on https://api.openai.com/v1/models
    # on 14 October 2026. The free OpenRouter embedding slugs were past
    # the daily cap while this feature was bottled.
    OPENAI_EMBEDDING = "text-embedding-3-small"

    # No :free image model was listed that day. OpenRouter paid default.
    IMAGE = "google/gemini-2.5-flash-image"

    # Cheapest OpenAI image model on https://api.openai.com/v1/models on
    # 14 October 2026. dall-e-2 and dall-e-3 were gone. Smallest size is
    # 1024x1024. Pass provider_options: { quality: "low" } on paint.
    OPENAI_IMAGE = "gpt-image-1-mini"
    OPENAI_IMAGE_SIZE = "1024x1024"

    # Cheap OpenAI chat model that advertises function calling, tool_choice,
    # parallel tool calls, temperature, and structured output. Confirmed on
    # https://api.openai.com/v1/models on 14 October 2026. gpt-4.1-nano is
    # cheaper and is scheduled to shut down on 2026-10-23. gpt-5-nano is
    # cheaper, does not take temperature, and is a reasoning model.
    # Also reads images and PDFs on the Responses API. Audio on that
    # protocol raises UnsupportedAttachmentError.
    OPENAI_CHAT = "gpt-4.1-mini"

    # Second OpenAI chat id for a mid-conversation with_model switch.
    # Distinct from OPENAI_CHAT so the cassette shows the new id.
    # Cheaper than gpt-4.1-mini. Confirmed on the same models list.
    OPENAI_CHAT_SWITCH = "gpt-4o-mini"

    # OpenAI Decisions model. RubyLLM::Judge with provider: :openai posts
    # this id to https://api.openai.com/v1/decisions. Confirmed against
    # RubyLLM 2.1.1 (Protocols::OpenAI::Decisions) and OpenAI's Decisions
    # guide. LIVE_PROVIDER does not retarget it: the free OpenRouter slug
    # does not speak that endpoint. gpt-4.1-mini does not list judgment.
    OPENAI_JUDGMENT = "gpt-6-luna"

    # OpenAI Responses model that accepts the native tool_search tool.
    # gpt-4.1-mini and gpt-5.4-nano answer HTTP 400: Tool 'tool_search'
    # is not supported. OpenAI's tool search guide names gpt-5.4 and later.
    # Cheapest slug that accepted a live tool_search probe on
    # https://api.openai.com/v1/models on 15 October 2026 is gpt-5.4-mini.
    # LIVE_PROVIDER does not retarget it: the free OpenRouter slug does
    # not speak tool_search.
    OPENAI_CHAT_TOOL_SEARCH = "gpt-5.4-mini"

    # Chat Completions audio model, confirmed on the same models list.
    # The free OpenRouter audio slugs were past the daily cap that afternoon.
    OPENAI_AUDIO = "gpt-audio-mini"

    module_function

    # The provider a scenario was bottled with. LIVE=1 LIVE_PROVIDER=openai
    # or LIVE_PROVIDER=openrouter overrides it for that recording only.
    # Replay ignores LIVE_PROVIDER so the cassette body still matches.
    def recording_provider(provider)
      fallback = provider.to_sym
      return fallback unless ENV["LIVE"] == "1"

      name = ENV["LIVE_PROVIDER"].to_s.strip.downcase
      return fallback if name.empty?

      chosen = name.to_sym
      return chosen if %i[openai openrouter].include?(chosen)

      abort "LIVE_PROVIDER must be openai or openrouter."
    end

    def chat(provider:)
      case recording_provider(provider)
      when :openai
        { model: OPENAI_CHAT, provider: :openai }
      when :openrouter
        { model: CHAT, provider: :openrouter, assume_model_exists: true }
      end
    end

    def embed(provider:)
      case recording_provider(provider)
      when :openai
        { model: OPENAI_EMBEDDING, provider: :openai }
      when :openrouter
        { model: EMBEDDING_TEXT, provider: :openrouter, assume_model_exists: true }
      end
    end

    # kwargs for RubyLLM.paint on the bottled OpenAI image model.
    # LIVE_PROVIDER does not switch this: OpenRouter drops size.
    def image_paint(**extra)
      extra = extra.dup
      provider_options = { quality: "low" }.merge(extra.delete(:provider_options) || {})
      {
        model: OPENAI_IMAGE,
        provider: :openai,
        size: OPENAI_IMAGE_SIZE,
        provider_options: provider_options
      }.merge(extra)
    end

    def configure(config, provider:)
      case recording_provider(provider)
      when :openai
        config.openai_api_key = api_key("OPENAI_API_KEY")
        # Chat Completions emits a developer role unless this is set.
        # OpenAI's Responses API does not send that role. The flag stays
        # on so LIVE_PROVIDER=openrouter still sends system.
        config.openai_use_system_role = true
      when :openrouter
        config.openrouter_api_key = api_key("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        config.openai_use_system_role = true
      end
    end

    # OpenRouter's free model spends the cap on reasoning unless thinking
    # is off. gpt-4.1-mini has no off control, and with_thinking(false)
    # raises before the request is sent.
    def quiet_thinking(chat, provider:)
      chat.with_thinking(false) if recording_provider(provider) == :openrouter
      chat
    end

    def api_key(name)
      value = ENV[name].to_s
      placeholder = value.empty? || value == Cassettes::PLACEHOLDER_KEY
      if placeholder && ENV["LIVE"] == "1"
        abort "LIVE=1 needs #{name} in the environment. Never commit it."
      end

      placeholder ? Cassettes::PLACEHOLDER_KEY : value
    end
  end
end
