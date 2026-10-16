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

OpenAI `gpt-5-nano` takes `effort:` (`minimal`/`low`/`medium`/`high`) and needs `display: :summarized` for `thinking.text`. It has no off control and does not take `temperature` or `budget`. OpenRouter `nvidia/nemotron-3-super-120b-a12b:free` returns thinking text with a toggle; `with_thinking(false)` sends `reasoning.enabled false`; `budget:` becomes `reasoning.max_tokens`. `gpt-4.1-mini` raises `ArgumentError` on `with_thinking(false)`. LIVE_PROVIDER does not retarget these pinned slugs. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Rovaniemi duodji knife](01-rovaniemi-duodji-knife/) — available
02. [Ouagadougou bronze lost-wax](02-ouagadougou-bronze-lost-wax/) — available
03. [Hotan jade pebble](03-hotan-jade-pebble/) — available
04. [Aizawl puan cloth](04-aizawl-puan-cloth/) — available
05. [Paro dzong timber](05-paro-dzong-timber/) — available
06. [Shillong bamboo split](06-shillong-bamboo-split/) — available
07. [Agadez silver cross](07-agadez-silver-cross/) — available
08. [Khartoum hibiscus karkade](08-khartoum-hibiscus-karkade/) — available
09. [Omdurman toub cloth](09-omdurman-toub-cloth/) — available
10. [Gondar parchment folio](10-gondar-parchment-folio/) — available
11. [Hawassa sidama coffee](11-hawassa-sidama-coffee/) — available
12. [Évora cork plank](12-evora-cork-plank/) — available
13. [Córdoba guadamecí leather](13-cordoba-guadameci-leather/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | Default `with_thinking` on Nemotron; `thinking.text` is present |
| 02 | `effort: :low` on `gpt-5-nano`; the wire sends `reasoning.effort` |
| 03 | `budget: 1024` omitted on OpenAI, sent as `reasoning.max_tokens` on Nemotron |
| 04 | `display: :summarized` sends `summary: auto`; text may still be nil |
| 05 | `display: :omitted` keeps thinking on the wire without summary text |
| 06 | Streamed `chunk.thinking` with summarized display |
| 07 | `gpt-4.1-mini` disable intent raises on `chat.thinking`; no cassette |
| 08 | Nemotron `with_thinking(false)` sends `reasoning.enabled false` |
| 09 | `with_model` to another provider drops the earlier signature |
| 10 | `tokens.thinking` is already inside `tokens.output`; `cost.thinking` is nil |
| 11 | Agent `thinking` macro |
| 12 | Rails stores `thinking_text` and `thinking_signature` |
| 13 | Capstone: summarized, two asks, tokens, signature |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
