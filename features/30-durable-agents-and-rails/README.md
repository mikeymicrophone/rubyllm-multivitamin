# Durable agents and Rails

A persisted chat is resumable: `SupportAgent.find(chat_id)` then `complete` or `step`. One turn per job is `chat.step` then enqueue unless `complete?` or `waiting?`. ActiveJob Continuations checkpoint after each move. `requires_approval` parks across processes; `approve`/`deny` then `CompleteJob`. `chat.cancel` writes the halt for a background stream. Tools must be at-least-once safe. This sits on `acts_as_chat` / `chat_model`, not a second persistence API.

Official reference: [Durable Agents](https://rubyllm.com/durable-agents/) and [Rails integration](https://rubyllm.com/rails/).

## RubyLLM 2.1.1 entry points

- `SupportAgent.find(chat_id).complete`
- `chat.step` then `perform_later` unless `complete?` || `waiting?`
- `ActiveJob::Continuable` checkpoints
- `approve` / `deny` then `CompleteJob`
- `chat.cancel` across processes
- idempotent tools (`find_or_create_by!`)

## Providers that can record it

Durability is ActiveRecord plus jobs. The model calls inside `step` record on the chat provider: OpenAI `gpt-4.1-mini` (this catalog's Rails default) or OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`. Feature 10 already bottled `acts_as_chat`. These scenarios add the job loop, approval parking, and cancel-from-anywhere.

## Examples (0 of 13 bottled)

01. Port Ludlow one-turn job — planned
02. Dabob Bay find then complete — planned
03. Quilcene Continuable checkpoint — planned
04. Dosewallips approval parks the worker — planned
05. Duckabush deny from the web process — planned
06. Hamma Hamma cancel mid-stream — planned
07. Lilliwaup tool runs twice — planned
08. Skokomish waiting? skips enqueue — planned
09. Union Chat.find has no tools — planned
10. Tahuya batch of durable turns — planned
11. Dewatto MCP task pause — planned
12. Seabeck cancelled column — planned
13. Bangor watch job capstone — planned

Planned titles are proposals, not commitments. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) before filling a slot.
