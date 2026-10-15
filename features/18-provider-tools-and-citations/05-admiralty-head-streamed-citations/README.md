# Provider tools and citations · 05 · Admiralty Head streamed citations

The lighthouse at Admiralty Head, on the west side of Whidbey, dictates
the NOAA hail onto the watch phone. Search citations arrive on stream
chunks as well as on the completed message.

**What it teaches**

- `ask` with a block still runs `:web_search`.
- Some `Chunk` objects already have `citations`.
- `response.citations` is the full, deduplicated list.
- `server_tool_calls` on that message still names `web_search_call`.

**Files**

| File | Role |
| --- | --- |
| [`head_stream.rb`](head_stream.rb) | Streams the Admiralty Head NOAA hail |
| [`head_stream_test.rb`](head_stream_test.rb) | Replays the cassette |
| [`cassettes/head_stream.yml`](cassettes/head_stream.yml) | Live OpenAI SSE recording |

**Try it**

```sh
bundle exec ruby features/18-provider-tools-and-citations/05-admiralty-head-streamed-citations/head_stream_test.rb
```

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/18-provider-tools-and-citations/05-admiralty-head-streamed-citations/head_stream_test.rb
```

**Model**

`gpt-4.1-mini` with `provider: :openai`. Checked 15 October 2026.
