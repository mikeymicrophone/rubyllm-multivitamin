# Batches

`ask_later` stages a chat. `RubyLLM.embed_later` stages an embedding.
`RubyLLM.batch` submits them and returns a `RubyLLM::Batch` (`id`, `status`,
`complete?`, `refresh`, `messages` / `results`, `statuses`, `cost`, `tokens`,
`cancel`). One provider per batch. Mix chats and embeddings in one batch and
you get `ArgumentError`. Rails persists batch state in `ruby_llm_batches`.

Official reference: [Batches](https://rubyllm.com/batches/).

## RubyLLM 2.1.1 entry points

- `chat.ask_later` then `RubyLLM.batch(chats)`
- `RubyLLM.embed_later` then `RubyLLM.batch(requests)`
- `RubyLLM::Batch.find(id, provider:)`
- `batch.refresh`, `complete?`, `messages`, `results`
- `batch.statuses`, `cost`, `tokens`, `cancel`
- `ruby_llm_batches` / `RubyLLM::ActiveRecord::Batch`

## Providers that can record it

OpenAI and Azure (batch-capable deployment; Azure embedding batches are not in
RubyLLM). Anthropic and xAI (mixed models allowed). OpenRouter (model with
batch access; no cancel). Cohere, Bedrock (no tools or schema on chat
batches), Vertex AI (GCS). This catalog's cheap record path is OpenAI Batch on
`gpt-4.1-mini` or `text-embedding-3-small`. Free OpenRouter chat slugs usually
have no batch access.

## Examples (13 of 13 bottled)

01. [Asmara berbere-mill staged briefs](01-asmara-berbere-mill/) — available
02. [Plovdiv rose-attar Batch.find](02-plovdiv-rose-attar/) — available
03. [Galle lace-bobbin pending nil slots](03-galle-lace-bobbin/) — available
04. [Tamale calabash-bowl tool then rebatch](04-tamale-calabash-bowl/) — available
05. [Ushuaia lenga-bark embed_later](05-ushuaia-lenga-bark/) — available
06. [Berat wood-lattice mix raises](06-berat-wood-lattice/) — available
07. [Luxor alabaster-vase cost until complete](07-luxor-alabaster-vase/) — available
08. [Rabat zellige-tile cancel](08-rabat-zellige-tile/) — available
09. [Chisinau sunflower-press one-model rule](09-chisinau-sunflower-press/) — available
10. [Cali salsa-shoe Rails batch table](10-cali-salsa-shoe/) — available
11. [Ohrid pearl-nacre poll job](11-ohrid-pearl-nacre/) — available
12. [Split limestone-block headers dropped](12-split-limestone-block/) — available
13. [Vientiane pha-nung desk capstone](13-vientiane-pha-nung/) — available

## What each scenario adds

| Slot | What it adds |
| --- | --- |
| 01 | `ask_later` then `RubyLLM.batch` returns an id |
| 02 | `Batch.find(id, provider:)` from another process |
| 03 | `messages` keeps a `nil` slot per pending request |
| 04 | A live tool round, then `ask_later` rebatches the next turn |
| 05 | `embed_later` submits an embedding batch |
| 06 | Mixing chats and embeds raises `ArgumentError` (no HTTP) |
| 07 | `cost.total` is `nil` until the batch ends |
| 08 | `cancel` sets `raw_status` to cancelling or cancelled |
| 09 | OpenAI one-model rule raises before upload (no HTTP) |
| 10 | `ruby_llm_batches` stores `provider_batch_id` and `chat_ids` |
| 11 | A job calls `refresh` once per tick |
| 12 | `with_headers` stays on the Chat; the JSONL omits them |
| 13 | Capstone: stage, submit, find, refresh, read slots |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
