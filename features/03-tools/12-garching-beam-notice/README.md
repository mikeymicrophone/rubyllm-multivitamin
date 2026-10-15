# Tools · 12 · Garching beam-time notice

The beam-time clerk at FRM-II in Garching streams notice 1842. Chunk
arguments arrive as strings. `before_tool_call` receives the finished
Hash. `execute` reports progress while it opens the folio. The proposal
number `18465` is only on the tool result.

**What it teaches**

- A streamed tool call yields argument strings on the chunks, including
  an empty string when the tool name arrives.
- `before_tool_call` receives the finished arguments as a Hash.
  `JSON.parse` of the joined fragments equals that Hash.
- `after_tool_result` receives the Ruby return. A Hash becomes JSON only
  on the tool message.
- `after_tool_progress` receives `Tool#progress`.
- `chat.messages` keeps the assistant `tool_calls` and the `:tool` reply,
  and `Message#tool_results` joins them.
- The OpenAI SSE cassette contains `response.function_call_arguments.delta`.

**Files**

| File | Role |
| --- | --- |
| [`beam_stream.rb`](beam_stream.rb) | Streams the notice, with callbacks and progress |
| [`beam_stream_test.rb`](beam_stream_test.rb) | Checks fragments, callbacks, and replays the cassette |
| [`cassettes/beam_stream.yml`](cassettes/beam_stream.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/12-garching-beam-notice/beam_stream_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/12-garching-beam-notice/beam_stream_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
