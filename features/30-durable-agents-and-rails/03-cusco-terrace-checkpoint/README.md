# Durable agents and Rails · 03 · Cusco terrace checkpoint

ActiveJob::Continuable checkpoints after each chat.step and resumes after interruption.

The first execution stops after the model requests the terrace tool. The
serialized cursor is 1; the resumed job runs the tool and final answer
without repeating that first request.

**What it teaches**

- ActiveJob::Continuable checkpoints after each chat.step and resumes after interruption.
- Ruby idiom: Continuation cursor, explicit loop, and serialized resumption.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`terrace_checkpoint.rb`](terrace_checkpoint.rb) | Scenario, models and job flow |
| [`terrace_checkpoint_test.rb`](terrace_checkpoint_test.rb) | Persistence and handover assertions |
| [`cassettes/terrace_checkpoint.yml`](cassettes/terrace_checkpoint.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/03-cusco-terrace-checkpoint/terrace_checkpoint.rb
bundle exec ruby features/30-durable-agents-and-rails/03-cusco-terrace-checkpoint/terrace_checkpoint_test.rb
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
