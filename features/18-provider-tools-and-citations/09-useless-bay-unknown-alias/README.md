# Provider tools and citations · 09 · Useless Bay unknown alias

The clerk at Useless Bay, south of Mutiny Bay, first asks OpenAI to
fetch a NOAA page. `:web_fetch` is an Anthropic and OpenRouter alias.
On OpenAI Responses it raises `UnsupportedServerToolError` before HTTP,
listing the aliases this protocol actually has. The desk then searches.

**What it teaches**

- `with_provider_tools(:web_fetch)` raises
  `RubyLLM::UnsupportedServerToolError` on OpenAI.
- The message lists `:web_search`, `:file_search`, `:code_execution`,
  `:code_interpreter`, `:image_generation`, and `:mcp`.
- An unlisted tool still works as a raw Hash in the provider's shape.
- `:web_search` after the refusal still cites NOAA. That is the only
  HTTP call on the cassette.

**Files**

| File | Role |
| --- | --- |
| [`fetch_alias.rb`](fetch_alias.rb) | Refuses `:web_fetch`, then searches |
| [`fetch_alias_test.rb`](fetch_alias_test.rb) | Replays the cassette |
| [`cassettes/fetch_alias.yml`](cassettes/fetch_alias.yml) | Live OpenAI recording of the search only |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/09-useless-bay-unknown-alias/fetch_alias_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/09-useless-bay-unknown-alias/fetch_alias_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
