# Durable agents and Rails · 01 · Kyoto torii watch

One persisted move per ActiveJob; enqueue unless complete? or waiting?.

**What it teaches**

- One persisted move per ActiveJob; enqueue unless complete? or waiting?.
- Ruby idiom: Instance-owned scheduler and endless methods.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`torii_watch.rb`](torii_watch.rb) | Scenario, models and job flow |
| [`torii_watch_test.rb`](torii_watch_test.rb) | Persistence and handover assertions |
| [`cassettes/torii_watch.yml`](cassettes/torii_watch.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/01-kyoto-torii-watch/torii_watch.rb
bundle exec ruby features/30-durable-agents-and-rails/01-kyoto-torii-watch/torii_watch_test.rb
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
