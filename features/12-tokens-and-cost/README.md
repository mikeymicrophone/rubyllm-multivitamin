# Tokens and cost

`response.tokens` is a `RubyLLM::Tokens`. `input`, `output`, `cache_read`, `cache_write`, and `thinking` are counts, or `nil` when the provider did not report that bucket. `response.cost` is a `RubyLLM::Cost`. `cost.total` is the provider's reported cost when `usage` includes one (OpenRouter's `usage.cost`), and otherwise a registry price. A missing price for tokens that were used makes `cost.total` nil rather than zero. A reported zero stays zero: free slugs often report `cost: 0`.

`chat.tokens` and `chat.cost` sum the attempts on that chat, including retries and cancellations that never produced a message. `max_tokens?` is the finish reason for a cut-off reply. `RubyLLM::ContextLengthExceededError` is the error for a prompt the model refuses, and it is not retried.

Official reference: [Tokens and costs](https://rubyllm.com/cost-and-usage-tracking/).

## Free models

`nvidia/nemotron-3-super-120b-a12b:free`. OpenRouter reports `usage.cost`, so `cost.total` is the reported number (often `0`) rather than a registry estimate. Fallback: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.

## Examples (0 of 13 bottled)

01. Token counts on a Point Wilson brief — planned
02. A reported zero cost on a free model — planned
03. chat.tokens across two watch questions — planned
04. A long board versus a one-line hail — planned
05. max output tokens and finish_reason :max_tokens — planned
06. Cache fields nil when the provider omits them — planned
07. Reported cost instead of a registry price — planned
08. Usage on the final streamed chunk — planned
09. Summing a watch's chats — planned
10. Nil total when nobody reported a price — planned
11. Tokens on a tool round — planned
12. A cancelled attempt still counted on the chat — planned
13. A watch ledger of per-turn and total cost — planned

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `tokens.input` and `tokens.output` are integers |
| 02 | `cost.total` equals the reported `0`, not nil |
| 03 | The chat's input tokens are at least the sum of the two replies' inputs |
| 04 | The longer prompt reports more input tokens |
| 05 | `with_max_output_tokens` small enough that `max_tokens?` is true |
| 06 | `cache_read` is nil, and nil is not treated as zero in the assertion |
| 07 | The cassette's `usage.cost` is what `cost.total` returns |
| 08 | The stream's final message carries usage from `stream_options` |
| 09 | `Cost.aggregate` across two messages |
| 10 | An assumed model with no `usage.cost` and no registry price yields nil |
| 11 | Tool-call turns still have input and output counts |
| 12 | `chat.cost` includes an attempt that `cancel` stopped |
| 13 | Capstone: print a ledger from `tokens` and `cost` for each turn and the chat |

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
