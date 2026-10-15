# Tokens and cost

`response.tokens` is a `RubyLLM::Tokens`. `input`, `output`, `cache_read`, `cache_write`, and `thinking` are counts, or `nil` when the provider did not report that bucket. `response.cost` is a `RubyLLM::Cost`. `cost.total` is the provider's reported cost when `usage` includes one (OpenRouter's `usage.cost`), and otherwise a registry price. A missing price for tokens that were used makes `cost.total` nil rather than zero. A reported zero stays zero: free slugs often report `cost: 0`.

`chat.tokens` and `chat.cost` sum the attempts on that chat, including retries and cancellations that never produced a message. `max_tokens?` is the finish reason for a cut-off reply. `RubyLLM::ContextLengthExceededError` is the error for a prompt the model refuses, and it is not retried.

Official reference: [Tokens and costs](https://rubyllm.com/cost-and-usage-tracking/).

## Free models

`nvidia/nemotron-3-super-120b-a12b:free`. OpenRouter reports `usage.cost`, so `cost.total` is the reported number (often `0`) rather than a registry estimate. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.

## Examples (13 of 13 bottled)

01. [Point Wilson kelp-ledge token tally](01-point-wilson-kelp-ledge-tokens/) — available
02. [Foulweather Bluff fog-signal zero](02-foulweather-bluff-fog-signal/) — available
03. [Protection Island auklet-watch totals](03-protection-island-auklet-watch/) — available
04. [Sequim Bay geoduck raft versus hail](04-sequim-bay-geoduck-raft/) — available
05. [Point No Point current-gate cap](05-point-no-point-current-gate/) — available
06. [Agate Pass tidal-race cache and thinking](06-agate-pass-tidal-race/) — available
07. [Ballard Locks salmon-count reported price](07-ballard-locks-salmon-count/) — available
08. [Bush Point flood-table stream usage](08-bush-point-flood-table/) — available
09. [Penn Cove mussel-raft tenant tallies](09-penn-cove-mussel-raft/) — available
10. [Roche Harbor customs-float unpriced clerk](10-roche-harbor-customs-float/) — available
11. [Cattle Point bull-kelp harvest tools](11-cattle-point-bull-kelp/) — available
12. [Turn Point current-halt cancelled usage](12-turn-point-current-halt/) — available
13. [Haro Strait watch ledger](13-haro-strait-watch-ledger/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `tokens.input` and `tokens.output` are integers |
| 02 | `cost.total` equals the reported `0`, not nil |
| 03 | The chat's input tokens equal the sum of the two replies' inputs |
| 04 | The longer prompt reports more input tokens |
| 05 | `with_max_output_tokens` small enough that `max_tokens?` is true |
| 06 | Cache buckets keep the provider's zeros; `thinking` is present |
| 07 | The cassette's `usage.cost` is what `cost.total` returns |
| 08 | The stream's final chunk carries usage from `stream_options` |
| 09 | `Cost.aggregate` and `with_usage_owner` across two tenants |
| 10 | An assumed model with no `usage.cost` on a bare Tokens yields nil |
| 11 | Tool-call turns still have input and output counts |
| 12 | `chat.cost` includes an attempt that `cancel` stopped |
| 13 | Capstone: a ledger, a budget, and `cost_for` across two models |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
