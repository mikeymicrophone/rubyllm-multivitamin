# Durable agents and Rails · 10 · Wellington cable car batch

Schedule a bounded batch by persisted IDs; reapply provider context on every find.

**What it teaches**

- Schedule a bounded batch by persisted IDs; reapply provider context on every find.
- Ruby idiom: Lazy enumeration, zip/sum, filter_map, and an isolated context.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`cable_car_batch.rb`](cable_car_batch.rb) | Scenario, models and job flow |
| [`cable_car_batch_test.rb`](cable_car_batch_test.rb) | Persistence and handover assertions |
| [`cassettes/cable_car_batch.yml`](cassettes/cable_car_batch.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/10-wellington-cable-car-batch/cable_car_batch.rb
bundle exec ruby features/30-durable-agents-and-rails/10-wellington-cable-car-batch/cable_car_batch_test.rb
```

**Fixture provenance**

The cassette is **hand-authored**, not a live recording. Requests were
captured from this script through RubyLLM 2.1.1's encoder with WebMock;
provider replies and usage are illustrative fixtures in the real wire format.
Replay checks the persistence and job behavior; it does not establish live
provider behavior. Re-record with `LIVE=1 OPENROUTER_API_KEY=...`.

**Model**

OpenRouter `nvidia/nemotron-3-super-120b-a12b:free`. Pinned explicitly; `LIVE_PROVIDER` does not
retarget these durable agent declarations. Each script boots an in-memory
SQLite database. Rehydration uses separate record instances and serialized
job payloads in one process; it is not a persistent deployment across script
invocations. ActiveJob continuations require Rails 8.1 or newer.
