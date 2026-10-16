# Durable agents and Rails · 12 · Rapa Nui quarry stop

cancelled is a persisted request consumed by the next worker checkpoint; no HTTP is needed.

**What it teaches**

- cancelled is a persisted request consumed by the next worker checkpoint; no HTTP is needed.
- Ruby idiom: Immutable Data result and local state transitions.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`quarry_stop.rb`](quarry_stop.rb) | Scenario, models and job flow |
| [`quarry_stop_test.rb`](quarry_stop_test.rb) | Persistence and handover assertions |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/12-rapa-nui-quarry-stop/quarry_stop.rb
bundle exec ruby features/30-durable-agents-and-rails/12-rapa-nui-quarry-stop/quarry_stop_test.rb
```

No HTTP call: the persisted cancellation is consumed before generation. No cassette is needed.

**Model**

OpenAI `gpt-4.1-mini`. Pinned explicitly; `LIVE_PROVIDER` does not
retarget these durable agent declarations. Each script boots an in-memory
SQLite database. Rehydration uses separate record instances and serialized
job payloads in one process; it is not a persistent deployment across script
invocations. ActiveJob continuations require Rails 8.1 or newer.
