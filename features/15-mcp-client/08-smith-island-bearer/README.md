# MCP client · 08 · Smith Island bearer and OAuth

The weather clerk on Smith Island reads the posted glass. The loopback MCP requires a bearer token. A second class uses `oauth grant: :client_credentials` after a 401 challenge. Plain HTTP is allowed on 127.0.0.1.

**What it teaches**

- `bearer_token` sends `Authorization` on every request.
- `oauth grant: :client_credentials` obtains a token after 401.
- Loopback HTTP is allowed; other hosts need HTTPS.

**Files**

| File | Role |
| --- | --- |
| [`weather_token.rb`](weather_token.rb) | Starts the loopback desk, bearer chat, OAuth tools |
| [`weather_token_test.rb`](weather_token_test.rb) | Replays the cassette |
| [`desk.json`](desk.json) | Barometer tool for the HTTP desk |
| [`cassettes/weather_token.yml`](cassettes/weather_token.yml) | Live OpenAI recording plus loopback MCP and OAuth |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/08-smith-island-bearer/weather_token_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/08-smith-island-bearer/weather_token_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
