# MCP client · 13 · Admiralty Inlet capstone

The watch clerk at Point Wilson reads the tide board, then the horn card, with the lens-latch resource attached on the follow-up. One stdio desk, prefixed names, two asks.

**What it teaches**

- A class, `with_mcp`, a resource, and a follow-up ask share one desk.
- `only` and `prefix` keep `admiralty_posted_tide_board` and `admiralty_posted_horn_card`.
- The second question uses the earlier tool result without repeating the board.

**Files**

| File | Role |
| --- | --- |
| [`watch_capstone.rb`](watch_capstone.rb) | The watch desk, the latch card, and two questions |
| [`watch_capstone_test.rb`](watch_capstone_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Tide, horn, and latch resource |
| [`cassettes/watch_capstone.yml`](cassettes/watch_capstone.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/13-admiralty-inlet-capstone/watch_capstone_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/13-admiralty-inlet-capstone/watch_capstone_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
