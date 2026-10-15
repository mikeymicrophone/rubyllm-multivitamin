# Provider tools and citations · 01 · Diamond Point web search hail

The radio clerk at Diamond Point, on the west shore of Discovery Bay,
has to name the NOAA gauge Alden copies before leaving the kelp ledge.
`with_provider_tools(:web_search)` runs that lookup on OpenAI, not as a
local Ruby tool.

**What it teaches**

- `chat.with_provider_tools(:web_search)` sends `"type":"web_search"`.
- `response.server_tool_calls` includes a `web_search_call`.
- `tokens.server_tool_use` reports `web_search_requests`.
- `response.citations` is the normalized list. This recording's
  `annotations` were empty, so the list is empty even after a search.
  Later slots show filled `url` citations.

**Files**

| File | Role |
| --- | --- |
| [`diamond_search.rb`](diamond_search.rb) | Hails NOAA from Diamond Point |
| [`diamond_search_test.rb`](diamond_search_test.rb) | Replays the cassette |
| [`cassettes/diamond_search.yml`](cassettes/diamond_search.yml) | Live OpenAI recording of `gpt-4.1-mini` with `:web_search` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/18-provider-tools-and-citations/01-diamond-point-web-search/diamond_search_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/01-diamond-point-web-search/diamond_search_test.rb
```

The helper strips `Authorization`. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. Free OpenRouter
slugs rarely advertise hosted tools. Checked 15 October 2026.
