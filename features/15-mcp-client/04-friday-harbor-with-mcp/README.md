# MCP client · 04 · Friday Harbor with_mcp

The berth clerk at Friday Harbor asks whether berth 7 has room for the seiner Kulshan. The length is not in the question. `with_mcp` connects the desk; `with_mcp(nil)` clears it.

**What it teaches**

- `with_mcp` connects a server to a chat.
- `chat.mcp.friday_harbor_berth_desk` reads it by name.
- `with_mcp(nil)` disconnects the desk.

**Files**

| File | Role |
| --- | --- |
| [`berth_mcp.rb`](berth_mcp.rb) | Connects the berth desk and asks for berth 7 |
| [`berth_mcp_test.rb`](berth_mcp_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile for berth_length |
| [`cassettes/berth_mcp.yml`](cassettes/berth_mcp.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/04-friday-harbor-with-mcp/berth_mcp_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/04-friday-harbor-with-mcp/berth_mcp_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
