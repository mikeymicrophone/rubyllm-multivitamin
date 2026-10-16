# frozen_string_literal: true

# OpenRouter slugs used by this feature. Free catalog first; paid
# openai/gpt-4.1-mini (and nano) when CONFIGURATION_OPENROUTER_PAID=1
# or the free slugs hit the daily cap. Still provider: :openrouter, so
# HTTP-Referer and X-OpenRouter-Title stay on the wire. A small output
# cap is set because this workspace's OpenRouter key could not afford
# the default 65536 max_tokens on the paid slugs.

module ConfigurationPaidOpenrouter
  CHAT = { model: "openai/gpt-4.1-mini", provider: :openrouter, assume_model_exists: true }.freeze
  SPARE = { model: "openai/gpt-4.1-nano", provider: :openrouter, assume_model_exists: true }.freeze
  EMBED = { model: "openai/text-embedding-3-small", provider: :openrouter, assume_model_exists: true }.freeze
  OUTPUT_CAP = 512

  module_function

  def paid?
    ENV["CONFIGURATION_OPENROUTER_PAID"] == "1"
  end

  def chat_args
    if Multivitamin::Models.recording_provider(:openrouter) == :openai
      Multivitamin::Models.chat(provider: :openai)
    elsif paid?
      CHAT.dup
    else
      Multivitamin::Models.chat(provider: :openrouter)
    end
  end

  def spare_args
    if Multivitamin::Models.recording_provider(:openrouter) == :openai
      { model: Multivitamin::Models::OPENAI_CHAT_SWITCH, provider: :openai }
    elsif paid?
      SPARE.dup
    else
      {
        model: Multivitamin::Models::CHAT_FALLBACK,
        provider: :openrouter,
        assume_model_exists: true
      }
    end
  end

  def embed_args
    if paid?
      EMBED.dup
    else
      Multivitamin::Models.embed(provider: :openrouter)
    end
  end

  def prepare(chat)
    chat.with_max_output_tokens(OUTPUT_CAP)
    quiet_thinking_if_supported(chat)
    chat
  end

  def quiet_thinking_if_supported(chat)
    return if paid?
    return if Multivitamin::Models.recording_provider(:openrouter) == :openai

    model_id = chat.model&.id.to_s
    return unless model_id.empty? || model_id.include?("nemotron-3-super")

    Multivitamin::Models.quiet_thinking(chat, provider: :openrouter)
  end
end
