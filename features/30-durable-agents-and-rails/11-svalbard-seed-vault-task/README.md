# Durable agents and Rails · 11 · Svalbard seed vault task

Persist an MCP task on the tool call; a fresh Agent.find checks once per scheduled job.

**What it teaches**

- Persist an MCP task on the tool call; a fresh Agent.find checks once per scheduled job.
- Ruby idiom: MCP task snapshots, ensure cleanup, and delayed polling jobs.
- The tiny application owns its chat and message classes; RubyLLM owns model,
  tool-call and usage tables. Shared boot and queue plumbing live in
  [`support/durable.rb`](../../../support/durable.rb).

**Files**

| File | Role |
| --- | --- |
| [`seed_vault_task.rb`](seed_vault_task.rb) | Scenario, models and job flow |
| [`seed_vault_task_test.rb`](seed_vault_task_test.rb) | Persistence and handover assertions |
| [`cassettes/seed_vault_task.yml`](cassettes/seed_vault_task.yml) | Hand-authored HTTP fixture |

**Try it**

```sh
bundle exec ruby features/30-durable-agents-and-rails/11-svalbard-seed-vault-task/seed_vault_task.rb
bundle exec ruby features/30-durable-agents-and-rails/11-svalbard-seed-vault-task/seed_vault_task_test.rb
```

**Fixture provenance**

The cassette is **hand-authored**, not a live recording. Requests were
captured from this script through RubyLLM 2.1.1's encoder with WebMock;
provider replies and usage are illustrative fixtures in the real wire format.
Replay checks the persistence and job behavior; it does not establish live
provider behavior. Re-record with `LIVE=1 OPENAI_API_KEY=...`.

The MCP discovery, task and poll responses are also hand-authored.
`VAULT_MCP_URL` must point to a compatible server to re-record; the reserved
`.invalid` URL deliberately has no live service. The harness drains scheduled
jobs immediately; a real queue respects the five-second polling delay.

**Model**

OpenAI `gpt-4.1-mini`. Pinned explicitly; `LIVE_PROVIDER` does not
retarget these durable agent declarations. Each script boots an in-memory
SQLite database. Rehydration uses separate record instances and serialized
job payloads in one process; it is not a persistent deployment across script
invocations. ActiveJob continuations require Rails 8.1 or newer.
