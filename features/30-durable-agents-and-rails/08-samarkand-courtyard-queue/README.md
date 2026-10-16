# Durable agents and Rails · 08 · Samarkand courtyard queue

A mixed tool batch does available work before waiting? stops re-enqueueing.

**What it teaches**

- A mixed tool batch does available work before waiting? stops re-enqueueing.
- Ruby idiom: Class and instance tools together, each_with_object, and callbacks.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`courtyard_queue.rb`](courtyard_queue.rb) | Scenario, models and job flow |
| [`courtyard_queue_test.rb`](courtyard_queue_test.rb) | Persistence and handover assertions |
| [`cassettes/courtyard_queue.yml`](cassettes/courtyard_queue.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/08-samarkand-courtyard-queue/courtyard_queue.rb
bundle exec ruby features/30-durable-agents-and-rails/08-samarkand-courtyard-queue/courtyard_queue_test.rb
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
