# frozen_string_literal: true

# Cheap OpenRouter slugs used by this feature when the :free catalog is
# past the daily cap. Still provider: :openrouter, so HTTP-Referer and
# X-OpenRouter-Title are sent. A small output cap is required: this
# workspace's OpenRouter key could not afford the default 65536 max_tokens.

module ConfigurationPaidOpenrouter
  CHAT = { model: "openai/gpt-4.1-mini", provider: :openrouter, assume_model_exists: true }.freeze
  SPARE = { model: "openai/gpt-4.1-nano", provider: :openrouter, assume_model_exists: true }.freeze
  EMBED = { model: "openai/text-embedding-3-small", provider: :openrouter, assume_model_exists: true }.freeze
  OUTPUT_CAP = 512

  module_function

  def chat_args
    if Multivitamin::Models.recording_provider(:openrouter) == :openai
      Multivitamin::Models.chat(provider: :openai)
    else
      CHAT.dup
    end
  end

  def spare_args
    if Multivitamin::Models.recording_provider(:openrouter) == :openai
      { model: "gpt-4.1-nano", provider: :openai }
    else
      SPARE.dup
    end
  end

  def embed_args
    EMBED.dup
  end

  def prepare(chat)
    chat.with_max_output_tokens(OUTPUT_CAP)
    chat
  end
end
