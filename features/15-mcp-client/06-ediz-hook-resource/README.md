# MCP client · 06 · Ediz Hook resource attachment

The buoy clerk at Ediz Hook reads the battery card for bell buoy EH-2. The card is an MCP resource. `ask(..., with: card)` attaches it like any other file. RubyLLM never fetches the `watch://` URI itself.

**What it teaches**

- `desk.resource(uri)` reads through the server.
- `content` is the markdown text.
- `ask` takes the resource with `with:`. The URI path ends in `.md` so `to_attachment` sniffs text, not `application/octet-stream`.

**Files**

| File | Role |
| --- | --- |
| [`buoy_card.rb`](buoy_card.rb) | Reads the battery card and attaches it |
| [`buoy_card_test.rb`](buoy_card_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile with the battery resource |
| [`cassettes/buoy_card.yml`](cassettes/buoy_card.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/06-ediz-hook-resource/buoy_card_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/06-ediz-hook-resource/buoy_card_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
