# Durable agents and Rails · 13 · Marrakesh medina handover

Capstone: bounded turns, persisted approval, idempotent issue, and a fresh-worker handover.

The first one-move allowance stops with runnable work still pending. A
second dispatch reads the gate window and parks for approval. The approved
pass then runs in a two-move allowance and produces the handover.

**What it teaches**

- Capstone: bounded turns, persisted approval, idempotent issue, and a fresh-worker handover.
- Ruby idiom: Scoped refinement, proc stop policy, bounded jobs, and find patterns.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`medina_handover.rb`](medina_handover.rb) | Scenario, models and job flow |
| [`medina_handover_test.rb`](medina_handover_test.rb) | Persistence and handover assertions |
| [`cassettes/medina_handover.yml`](cassettes/medina_handover.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/13-marrakesh-medina-handover/medina_handover.rb
bundle exec ruby features/30-durable-agents-and-rails/13-marrakesh-medina-handover/medina_handover_test.rb
```

**Fixture provenance**

The cassette is **hand-authored**, not a live recording. Requests were
captured from this script through RubyLLM 2.1.1's encoder with WebMock;
provider replies and usage are illustrative fixtures in the real wire format.
Replay checks the persistence and job behavior; it does not establish live
provider behavior. Re-record with `LIVE=1 OPENAI_API_KEY=...`.

**Model**

OpenAI `gpt-4.1-mini`. Pinned explicitly; `LIVE_PROVIDER` does not
retarget these durable agent declarations. Each script boots an in-memory
SQLite database. Rehydration uses separate record instances and serialized
job payloads in one process; it is not a persistent deployment across script
invocations. ActiveJob continuations require Rails 8.1 or newer.
