# Durable agents and Rails

A persisted chat resumes through `Agent.find(chat_id)`: its history comes
from `acts_as_chat`, and the agent declaration restores tools, instructions,
and runtime options. `step` makes one move; a job queues the next move unless
`complete?` or `waiting?`. `complete` drives the loop to an answer or an
external wait. ActiveJob continuations checkpoint between moves.

Official reference: [Durable Agents](https://rubyllm.com/durable-agents/) and
[Rails integration](https://rubyllm.com/rails/).

## RubyLLM 2.1.1 entry points

- Agent `chat_model`, `create!`, and `find(chat_id)`
- `ask_later`, `step`, `complete`, `complete?`, and `waiting?`
- `ActiveJob::Continuable` with a cursor advanced after each persisted move
- Tool `requires_approval`, persisted `approve` / `deny`, then a completion job
- `cancel` on another record; `RubyLLM::CancelledError` on the worker
- Idempotent tools with `find_or_create_by!` and a unique business-key index
- MCP `extension :tasks`, persisted task state, and scheduled `complete` checks

## Providers and fixture provenance

Slots 01–09, 11 and 13 use OpenAI `gpt-4.1-mini`; slot 06 explicitly uses
Chat Completions for its stream. Slot 10 uses OpenRouter
`nvidia/nemotron-3-super-120b-a12b:free` with an isolated context. Slot 12
stops before HTTP and needs no cassette. These agent declarations pin their
providers: `LIVE_PROVIDER` does not retarget them.

All twelve cassettes are **hand-authored**, not live recordings. Requests
were captured from the scripts through the pinned RubyLLM 2.1.1 encoder
using WebMock without a network connection. Responses and usage are
illustrative fixtures in the provider's wire format. Re-record with `LIVE=1`
and the corresponding provider key. Svalbard also needs `VAULT_MCP_URL`
pointing to a compatible MCP service; its `.invalid` endpoint is a fixture.

Each application keeps its own models and domain tables in its scenario
folder. [`support/durable.rb`](../../support/durable.rb) reuses the existing
ActiveRecord schema boot and runtime configuration, seeds the internal model
registry, and supplies a bounded queue drain. Jobs use the real ActiveJob test
adapter and execute serialized payloads through ActiveJob's deserializer.
Continuations require ActiveJob 8.1 or newer.

The in-memory SQLite database lasts one script invocation. Fresh record
instances exercise rehydration; the examples do not launch separate OS
processes or a production queue. Scheduled delays are drained immediately
by the local harness. Production workers must respect polling delays, use a
persistent database and queue, and keep tool side effects safe to repeat.

## Examples (13 of 13 bottled)

01. [Kyoto torii watch](01-kyoto-torii-watch/) — available
02. [Petra cistern handover](02-petra-cistern-handover/) — available
03. [Cusco terrace checkpoint](03-cusco-terrace-checkpoint/) — available
04. [Zanzibar dhow permit](04-zanzibar-dhow-permit/) — available
05. [Bergen Fløyen closure](05-bergen-floyen-closure/) — available
06. [Iguazú catwalk cancel](06-iguazu-catwalk-cancel/) — available
07. [Luang Prabang boat receipt](07-luang-prabang-boat-receipt/) — available
08. [Samarkand courtyard queue](08-samarkand-courtyard-queue/) — available
09. [Venice tide gate](09-venice-tide-gate/) — available
10. [Wellington cable car batch](10-wellington-cable-car-batch/) — available
11. [Svalbard seed vault task](11-svalbard-seed-vault-task/) — available
12. [Rapa Nui quarry stop](12-rapa-nui-quarry-stop/) — available
13. [Marrakesh medina handover](13-marrakesh-medina-handover/) — available

## What each scenario adds

| Slot | Durable behavior | Ruby idiom |
| --- | --- | --- |
| 01 | One persisted move per ActiveJob; enqueue unless complete? or waiting?. | Instance-owned scheduler and endless methods |
| 02 | Agent.find restores configuration and resumes staged history by ID. | Customized Data record, module functions, and then |
| 03 | ActiveJob::Continuable checkpoints after each chat.step and resumes after interruption. | Continuation cursor, explicit loop, and serialized resumption |
| 04 | requires_approval parks a job; another record approves by ID before CompleteJob. | Fluent configuration and a lambda decision boundary |
| 05 | A web-process denial persists; the resumed worker returns a denial result without running the tool. | Decision table and case/in destructuring |
| 06 | Persisted cancellation reaches a streaming worker; cleanup removes the unfinished assistant. | Chunk callback closure and a separate controller record |
| 07 | At-least-once tool execution needs a durable business key; a lost result must not duplicate the receipt. | Database uniqueness, find_or_create_by!, and retry after failure |
| 08 | A mixed tool batch does available work before waiting? stops re-enqueueing. | Class and instance tools together, each_with_object, and callbacks |
| 09 | Raw record find has history; Agent.find also restores the tools needed to execute it. | Bound method passed with &, map, and runtime rehydration |
| 10 | Schedule a bounded batch by persisted IDs; reapply provider context on every find. | Lazy enumeration, zip/sum, filter_map, and an isolated context |
| 11 | Persist an MCP task on the tool call; a fresh Agent.find checks once per scheduled job. | MCP task snapshots, ensure cleanup, and delayed polling jobs |
| 12 | cancelled is a persisted request consumed by the next worker checkpoint; no HTTP is needed. | Immutable Data result and local state transitions |
| 13 | Capstone: bounded turns, persisted approval, idempotent issue, and a fresh-worker handover. | Scoped refinement, proc stop policy, bounded jobs, and find patterns |

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for scenario conventions.
