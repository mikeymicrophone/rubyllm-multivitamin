# MCP client · 12 · Juan de Fuca deferred tool search

The chart clerk for the Strait of Juan de Fuca has ten cards. `defer` keeps them out of context. The model searches, finds the Race Rocks current gate, and reads 2.8 kn.

**What it teaches**

- `defer` on the class marks every server tool.
- `with_mcp(..., defer: true)` defers them for this chat.
- The Responses API sends `defer_loading`. The model searches, then calls `current_gate`.

**Files**

| File | Role |
| --- | --- |
| [`current_search.rb`](current_search.rb) | Defers the chart desk and asks the current gate |
| [`current_search_test.rb`](current_search_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Ten Juan de Fuca tools |
| [`cassettes/current_search.yml`](cassettes/current_search.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/12-juan-de-fuca-defer/current_search_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/12-juan-de-fuca-defer/current_search_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-5.4-mini` with `provider: :openai`. That is the cheapest OpenAI slug that accepted a live `tool_search` probe. `gpt-4.1-mini` and `gpt-5.4-nano` reject it with HTTP 400. `LIVE_PROVIDER` does not retarget this slot. The id was on OpenAI's models list on 15 October 2026.
