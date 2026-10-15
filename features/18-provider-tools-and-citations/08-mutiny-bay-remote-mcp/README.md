# Provider tools and citations · 08 · Mutiny Bay remote MCP

The horn house at Mutiny Bay, inside Useless Bay, stores the blast log
on an Azure IoT Hub twin. The clerk looks the page up through OpenAI's
hosted Microsoft Learn connector. That is `with_provider_tools(mcp:)`,
not the first-party `RubyLLM::MCP` client in feature 15.

**What it teaches**

- `mcp: { name:, url: }` becomes `server_label` and `server_url`.
- `require_approval: "never"` lets the allowed tool run without a pause.
  Feature 19 covers local and remote approval.
- `server_tool_calls` includes `mcp_list_tools` and `mcp_call`.
- The `mcp_call` name is `microsoft_docs_search`.

**Files**

| File | Role |
| --- | --- |
| [`learn_mcp.rb`](learn_mcp.rb) | Hails Microsoft Learn from Mutiny Bay |
| [`learn_mcp_test.rb`](learn_mcp_test.rb) | Replays the cassette |
| [`cassettes/learn_mcp.yml`](cassettes/learn_mcp.yml) | Live OpenAI recording of the hosted MCP tool |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/08-mutiny-bay-remote-mcp/learn_mcp_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/08-mutiny-bay-remote-mcp/learn_mcp_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
