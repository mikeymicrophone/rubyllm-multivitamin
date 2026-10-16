# Durable agents and Rails · 09 · Venice tide gate

Raw record find has history; Agent.find also restores the tools needed to execute it.

**What it teaches**

- Raw record find has history; Agent.find also restores the tools needed to execute it.
- Ruby idiom: Bound method passed with &, map, and runtime rehydration.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`tide_gate.rb`](tide_gate.rb) | Scenario, models and job flow |
| [`tide_gate_test.rb`](tide_gate_test.rb) | Persistence and handover assertions |
| [`cassettes/tide_gate.yml`](cassettes/tide_gate.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/09-venice-tide-gate/tide_gate.rb
bundle exec ruby features/30-durable-agents-and-rails/09-venice-tide-gate/tide_gate_test.rb
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
