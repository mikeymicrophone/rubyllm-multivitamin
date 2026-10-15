# Moderation

`RubyLLM.moderate` returns a `RubyLLM::Moderation`. Read `flagged?`, `flagged_categories`, `category_scores`, and `results` for a batch of strings. `with:` screens images. The default model is OpenAI `omni-moderation-latest`. Bedrock guardrails use `provider: :bedrock` with no generation model. Other attachment types raise `UnsupportedAttachmentError`.

Official reference: [Moderation](https://rubyllm.com/moderation/).

## RubyLLM 2.1.1 entry points

- `RubyLLM.moderate "I love programming in Ruby."`
- `flagged?`, `flagged_categories`, `category_scores`
- `RubyLLM.moderate(["a", "b"])` and `moderation.results`
- `moderate(with: "profile.png")`
- `model: "mistral-moderation-2603"`
- `provider: :bedrock` guardrails

## Providers that can record it

OpenAI `omni-moderation-latest` (text and image). Mistral `mistral-moderation-2603`. Bedrock guardrails. OpenRouter has no separate moderation operation in 2.1.1. Anthropic, Gemini, xAI, and Cohere are dashes on the coverage grid. This catalog's cheap record path is OpenAI omni-moderation. A free OpenRouter chat slug is the wrong API.

## Examples (0 of 13 bottled)

01. Dosewallips clean hail — planned
02. Duckabush flagged categories — planned
03. Hamma Hamma several comments — planned
04. Lilliwaup profile photo — planned
05. Skokomish Mistral model — planned
06. Union Bedrock guardrail — planned
07. Tahuya image plus caption — planned
08. Dewatto WAV raises — planned
09. Seabeck empty scores — planned
10. Bangor pre-chat screen — planned
11. Keyport Rails photo job — planned
12. Poulsbo raw assessments — planned
13. Liberty Bay review desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
