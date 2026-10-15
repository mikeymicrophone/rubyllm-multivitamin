# MCP client · 09 · Bremerton listen and after_change

The dry dock clerk at Bremerton posts a sill card while the watch is open. `listen` hears the tool list change. `after_change` records `:tools`. The next ask can call `dry_dock_sill`.

**What it teaches**

- `after_change` runs on the MCP instance with `:tools`.
- `listen` hears announcements between requests.
- RubyLLM forgets the old list, so `tools` includes the sill card.

**Files**

| File | Role |
| --- | --- |
| [`gate_listen.rb`](gate_listen.rb) | Listens, posts the sill card, then asks the depth |
| [`gate_listen_test.rb`](gate_listen_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Stdio profile that can add dry_dock_sill |
| [`cassettes/gate_listen.yml`](cassettes/gate_listen.yml) | Live OpenAI recording |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/09-bremerton-listen/gate_listen_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/09-bremerton-listen/gate_listen_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
