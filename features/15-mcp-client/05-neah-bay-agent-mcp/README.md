# MCP client · 05 · Neah Bay agent mcp macro

The pilot clerk at Neah Bay boards the cutter Makah from a reusable agent. The agent declares the ladder desk with `mcp`, so `Agent.chat.ask` does not call `with_mcp` itself.

**What it teaches**

- `RubyLLM::Agent` declares servers with `mcp`.
- A block runs when the chat is built.
- `PilotBoardingClerk.chat.ask` uses those servers.

**Files**

| File | Role |
| --- | --- |
| [`pilot_agent.rb`](pilot_agent.rb) | The agent, the desk, and the ladder question |
| [`pilot_agent_test.rb`](pilot_agent_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile for pilot_ladder |
| [`cassettes/pilot_agent.yml`](cassettes/pilot_agent.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/05-neah-bay-agent-mcp/pilot_agent_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/05-neah-bay-agent-mcp/pilot_agent_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
