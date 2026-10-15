# MCP client · 01 · Point Wilson Learn URL

The kelp-ledge gauge on the foghorn tender Alden reports through Azure IoT Hub. The tide clerk at Point Wilson looks up device twins on the public Microsoft Learn MCP over Streamable HTTP.

**What it teaches**

- `RubyLLM::MCP` with `url` connects over Streamable HTTP.
- `only :microsoft_docs_search` hides fetch and code-sample search.
- `with_mcp` gives the chat that tool.
- The model calls `microsoft_docs_search` the way it calls a Ruby tool.

**Files**

| File | Role |
| --- | --- |
| [`tide_gauge_docs.rb`](tide_gauge_docs.rb) | The Microsoft Learn class and the gauge question |
| [`tide_gauge_docs_test.rb`](tide_gauge_docs_test.rb) | Replays the cassette |
| [`cassettes/tide_gauge_docs.yml`](cassettes/tide_gauge_docs.yml) | Live OpenAI recording plus Learn MCP HTTP |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/01-point-wilson-learn-url/tide_gauge_docs_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/01-point-wilson-learn-url/tide_gauge_docs_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
