# Extended thinking

`chat.with_thinking` enables reasoning with the model's registered controls. Pass `effort:`, `budget:`, `display:` (`:summarized`, `:omitted`). `with_thinking(false)` sends the registered off control and raises `ArgumentError` when the model has none (`gpt-4.1-mini` is that case). Read `response.thinking.text` and `thinking.signature`. Streamed chunks may carry `chunk.thinking`. `tokens.thinking` is already inside `tokens.output` for billing; do not add them.

Official reference: [Extended Thinking](https://rubyllm.com/thinking/).

## RubyLLM 2.1.1 entry points

- `chat.with_thinking` / `with_thinking(effort: :high, budget: 8000)`
- `with_thinking(false)` and the off-control `ArgumentError`
- `response.thinking.text` / `signature`
- `display: :summarized` / `:omitted`
- `chunk.thinking` on a stream
- `tokens.thinking` and `cost.thinking`

## Providers that can record it

OpenRouter reasoning slugs (`nvidia/nemotron-3-super-120b-a12b:free` returns thinking text; `with_thinking(false)` sends `reasoning.enabled false`). OpenAI reasoning models take `effort` and need `display: :summarized` for text; `gpt-4.1-mini` has no off control. Anthropic/Bedrock Claude (budget and effort). Gemini 2.5 budget / Gemini 3 effort. Mistral `reasoning_effort`, Cohere, DeepSeek, Ollama. This catalog already recorded Nemotron thinking on chat basics and streaming; new scenarios should pin effort/budget/display.

## Examples (0 of 13 bottled)

01. Saratoga Passage default thinking — planned
02. Coupeville effort low — planned
03. Penn Cove budget 1024 — planned
04. Fort Casey summarized display — planned
05. Admiralty Head thinking.text — planned
06. Bush Point streamed thinking chunks — planned
07. Lagoon Point gpt-4.1-mini no off control — planned
08. Mutiny Bay Nemotron enabled false — planned
09. Useless Bay with_model drops signatures — planned
10. Double Bluff tokens.thinking — planned
11. Hood Head agent thinking macro — planned
12. Tala Point max_tokens eats the answer — planned
13. Termination Point thinking desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
