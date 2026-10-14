# Tools · 12 · Juan de Fuca chart stream

The mate on the Strait of Juan de Fuca chart desk streams notice 1842.
The chunks carry the tool arguments as strings. The callback sees a
hash. The tool returns a hash, and the transcript stores JSON. The
spoken correction includes chart 18465, which is not in the question.

**What it teaches**

- Pass a block to `ask` while a tool is registered. Tool-call chunks
  keep `arguments` as a String. One chunk has the tool name and `""`.
- `before_tool_call` receives a `ToolCall` whose `arguments` are a Hash.
  Joining the fragment strings and parsing them equals that Hash. This
  is the same split the Cape Disappointment horn relief recorded.
- `after_tool_result` receives the Hash `execute` returned. The `:tool`
  message content is that hash rendered as JSON.
- `progress` inside `execute` fires `after_tool_progress` with a
  `RubyLLM::Progress`. The 1.x names `on_tool_call` and `on_tool_result`
  are not on 2.1.1.
- `Message#tool_calls` is on the assistant turn. `tool_call_id` is on
  the tool turn. `tool_results` links them.

**Files**

| File | Role |
| --- | --- |
| [`chart_stream.rb`](chart_stream.rb) | Streams the notice and records the callbacks |
| [`chart_stream_test.rb`](chart_stream_test.rb) | Replays the cassette |
| [`cassettes/chart_stream.yml`](cassettes/chart_stream.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/03-tools/12-juan-de-fuca-chart-stream/chart_stream_test.rb
```

The test replays the cassette. No API key is required. Tests that call the tool class directly do not need the network.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/03-tools/12-juan-de-fuca-chart-stream/chart_stream_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
