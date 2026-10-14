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
| [`chart_stream_test.rb`](chart_stream_test.rb) | Replays the cassette once it exists |
| [`cassettes/chart_stream.yml`](cassettes/chart_stream.yml) | Not recorded yet |

**Try it**

The cassette is not recorded. The test skips with `cassette pending live
recording`.

```sh
bundle exec ruby features/03-tools/12-juan-de-fuca-chart-stream/chart_stream_test.rb
```

Record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/03-tools/12-juan-de-fuca-chart-stream/chart_stream_test.rb
```

Do not hand-author the cassette.

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback:
`liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
