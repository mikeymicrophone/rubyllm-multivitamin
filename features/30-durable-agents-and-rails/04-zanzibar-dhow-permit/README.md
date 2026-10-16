# Durable agents and Rails · 04 · Zanzibar dhow permit

requires_approval parks a job; another record approves by ID before CompleteJob.

**What it teaches**

- requires_approval parks a job; another record approves by ID before CompleteJob.
- Ruby idiom: Fluent configuration and a lambda decision boundary.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`dhow_permit.rb`](dhow_permit.rb) | Scenario, models and job flow |
| [`dhow_permit_test.rb`](dhow_permit_test.rb) | Persistence and handover assertions |
| [`cassettes/dhow_permit.yml`](cassettes/dhow_permit.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/04-zanzibar-dhow-permit/dhow_permit.rb
bundle exec ruby features/30-durable-agents-and-rails/04-zanzibar-dhow-permit/dhow_permit_test.rb
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
