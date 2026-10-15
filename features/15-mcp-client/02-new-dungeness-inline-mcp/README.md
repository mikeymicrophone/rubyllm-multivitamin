# MCP client · 02 · New Dungeness inline MCP

The Fresnel lamp current logger at New Dungeness posts custom metrics to Azure Monitor. The lens keeper builds a Microsoft Learn client inline with `RubyLLM.mcp` instead of a class.

**What it teaches**

- `RubyLLM.mcp(url:)` builds a server from keywords.
- The name comes from the host: `learn_microsoft`.
- Without `only`, the chat sees every Learn tool, including fetch.

**Files**

| File | Role |
| --- | --- |
| [`lamp_current_docs.rb`](lamp_current_docs.rb) | Inline MCP and the lamp-current question |
| [`lamp_current_docs_test.rb`](lamp_current_docs_test.rb) | Replays the cassette |
| [`cassettes/lamp_current_docs.yml`](cassettes/lamp_current_docs.yml) | Live OpenAI recording plus Learn MCP HTTP |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/15-mcp-client/02-new-dungeness-inline-mcp/lamp_current_docs_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/15-mcp-client/02-new-dungeness-inline-mcp/lamp_current_docs_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
