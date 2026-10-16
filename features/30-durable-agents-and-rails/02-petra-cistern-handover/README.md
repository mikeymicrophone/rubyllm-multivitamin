# Durable agents and Rails · 02 · Petra cistern handover

Agent.find restores configuration and resumes staged history by ID.

**What it teaches**

- Agent.find restores configuration and resumes staged history by ID.
- Ruby idiom: Customized Data record, module functions, and then.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`cistern_handover.rb`](cistern_handover.rb) | Scenario, models and job flow |
| [`cistern_handover_test.rb`](cistern_handover_test.rb) | Persistence and handover assertions |
| [`cassettes/cistern_handover.yml`](cassettes/cistern_handover.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/02-petra-cistern-handover/cistern_handover.rb
bundle exec ruby features/30-durable-agents-and-rails/02-petra-cistern-handover/cistern_handover_test.rb
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
