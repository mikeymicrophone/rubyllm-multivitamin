# Tokens and cost

`response.tokens` is a `RubyLLM::Tokens`. `input`, `output`, `cache_read`, `cache_write`, and `thinking` are counts, or `nil` when the provider did not report that bucket. `response.cost` is a `RubyLLM::Cost`. `cost.total` is the provider's reported cost when `usage` includes one (OpenRouter's `usage.cost`), and otherwise a registry price. A missing price for tokens that were used makes `cost.total` nil rather than zero. A reported zero stays zero: free slugs often report `cost: 0`.

`chat.tokens` and `chat.cost` sum the attempts on that chat, including retries and cancellations that never produced a message. `max_tokens?` is the finish reason for a cut-off reply. `RubyLLM::ContextLengthExceededError` is the error for a prompt the model refuses, and it is not retried.

Official reference: [Tokens and costs](https://rubyllm.com/cost-and-usage-tracking/).

## Free models

`nvidia/nemotron-3-super-120b-a12b:free`. OpenRouter reports `usage.cost`, so `cost.total` is the reported number (often `0`) rather than a registry estimate. Fallback: `liquid/lfm-2.5-2.6b:free`. Slot 04 can fall back to OpenAI `gpt-4.1-mini` via `LIVE_PROVIDER=openai` if the free slug hits `free-models-per-day`. Checked 16 October 2026.

## Examples (13 of 13 bottled)

01. [Pokhara Sarangkot launch tokens](01-pokhara-sarangkot-tokens/) — available
02. [Ouarzazate kasbah flicker zero](02-ouarzazate-flicker-zero/) — available
03. [Bahir Dar teff-mill totals](03-bahir-dar-teff-mill/) — available
04. [Manaus açaí lot versus hail](04-manaus-acai-lot/) — available
05. [Quetzaltenango ash-gate cap](05-quetzaltenango-ash-gate/) — available
06. [Osh apricot-dry cache and thinking](06-osh-apricot-dry/) — available
07. [Puri ratha-spoke reported price](07-puri-ratha-spoke/) — available
08. [Cartagena tinto stream usage](08-cartagena-tinto-stream/) — available
09. [Cochabamba market tenant tallies](09-cochabamba-market-tenants/) — available
10. [Lahore truck-art unpriced clerk](10-lahore-truck-art-clerk/) — available
11. [Freetown gara-cloth harvest tools](11-freetown-gara-cloth/) — available
12. [Kano indigo-halt cancelled usage](12-kano-indigo-halt/) — available
13. [Dushanbe tanbur ledger](13-dushanbe-tanbur-ledger/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `tokens.input` and `tokens.output` are integers |
| 02 | `cost.total` equals the reported `0`, not nil |
| 03 | The chat's input tokens equal the sum of the two replies' inputs |
| 04 | The longer prompt reports more input tokens |
| 05 | `with_max_output_tokens` small enough that `max_tokens?` is true |
| 06 | Cache buckets keep the provider's zeros; `thinking` is present |
| 07 | The cassette's `usage.cost` is what `cost.total` returns; components are registry `$0` |
| 08 | The stream's final chunk carries usage from `stream_options` |
| 09 | `Cost.aggregate` and `with_usage_owner` across two tenants |
| 10 | An assumed model with no `usage.cost` on a bare Tokens yields nil |
| 11 | Tool-call turns still have input and output counts |
| 12 | A cancelled attempt stays on the chat; input is nil, `cost.total` is `0.0` |
| 13 | Capstone: a ledger, a budget, and `cost_for` across two models |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
