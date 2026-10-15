# Batches

`ask_later` stages a chat. `RubyLLM.embed_later` stages an embedding. `RubyLLM.batch` submits them and returns a `RubyLLM::Batch` (`id`, `status`, `complete?`, `refresh`, `messages` / `results`, `statuses`, `cost`, `tokens`, `cancel`). One provider per batch. Mix chats and embeddings in one batch and you get `ArgumentError`. Rails persists batch state in `ruby_llm_batches`.

Official reference: [Batches](https://rubyllm.com/batches/).

## RubyLLM 2.1.1 entry points

- `chat.ask_later` then `RubyLLM.batch(chats)`
- `RubyLLM.embed_later` then `RubyLLM.batch(requests)`
- `RubyLLM::Batch.find(id, provider:)`
- `batch.refresh`, `complete?`, `messages`, `results`
- `batch.statuses`, `cost`, `tokens`, `cancel`
- `ruby_llm_batches` / `RubyLLM::ActiveRecord::Batch`

## Providers that can record it

OpenAI and Azure (batch-capable deployment; Azure embedding batches are not in RubyLLM). Anthropic and xAI (mixed models allowed). OpenRouter (model with batch access; no cancel). Cohere, Bedrock (no tools or schema on chat batches), Vertex AI (GCS). This catalog's cheap record path is OpenAI Batch on `gpt-4.1-mini` or `text-embedding-3-small`. Free OpenRouter chat slugs usually have no batch access.

## Examples (0 of 13 bottled)

01. Meadow Point staged summaries — planned
02. Carkeek Batch.find from another process — planned
03. Richmond Beach failed slot nil — planned
04. Edmonds tool round then rebatch — planned
05. Possession Sound embed_later — planned
06. Gedney mix chats and embeds raises — planned
07. Hat Island cost after complete — planned
08. Priest Point cancel unfinished — planned
09. Tulalip one-model rule — planned
10. Camano Rails batch table — planned
11. Saratoga Passage poll job — planned
12. Coupeville custom headers dropped — planned
13. Penn Cove batch desk capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
