# Durable agents and Rails · 07 · Luang Prabang boat receipt

At-least-once tool execution needs a durable business key; a lost result must not duplicate the receipt.

**What it teaches**

- At-least-once tool execution needs a durable business key; a lost result must not duplicate the receipt.
- Ruby idiom: Database uniqueness, find_or_create_by!, and retry after failure.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`boat_receipt.rb`](boat_receipt.rb) | Scenario, models and job flow |
| [`boat_receipt_test.rb`](boat_receipt_test.rb) | Persistence and handover assertions |
| [`cassettes/boat_receipt.yml`](cassettes/boat_receipt.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/07-luang-prabang-boat-receipt/boat_receipt.rb
bundle exec ruby features/30-durable-agents-and-rails/07-luang-prabang-boat-receipt/boat_receipt_test.rb
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
