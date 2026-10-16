# Durable agents and Rails · 06 · Iguazú catwalk cancel

Persisted cancellation reaches a streaming worker; cleanup removes the unfinished assistant.

**What it teaches**

- Persisted cancellation reaches a streaming worker; cleanup removes the unfinished assistant.
- Ruby idiom: Chunk callback closure and a separate controller record.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`catwalk_cancel.rb`](catwalk_cancel.rb) | Scenario, models and job flow |
| [`catwalk_cancel_test.rb`](catwalk_cancel_test.rb) | Persistence and handover assertions |
| [`cassettes/catwalk_cancel.yml`](cassettes/catwalk_cancel.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/06-iguazu-catwalk-cancel/catwalk_cancel.rb
bundle exec ruby features/30-durable-agents-and-rails/06-iguazu-catwalk-cancel/catwalk_cancel_test.rb
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
