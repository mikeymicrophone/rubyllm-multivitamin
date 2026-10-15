# MCP client · 11 · Port Angeles background tasks

The net loft clerk at Port Angeles renders the twine ledger. The desk answers with a task. The chat pauses. The first `complete` still finds it working. The second `complete` resumes with 14 spools.

**What it teaches**

- `extension :tasks` lets the server return a task.
- `awaiting_tasks?` is true; `complete` checks once, without waiting.
- A later `complete` resumes when the ledger is ready.

**Files**

| File | Role |
| --- | --- |
| [`twine_task.rb`](twine_task.rb) | Starts the ledger task and completes twice |
| [`twine_task_test.rb`](twine_task_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile with the twine ledger task |
| [`cassettes/twine_task.yml`](cassettes/twine_task.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/11-port-angeles-tasks/twine_task_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/11-port-angeles-tasks/twine_task_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
