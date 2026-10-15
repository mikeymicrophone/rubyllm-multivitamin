# Tool approval and loop control · 05 · Duckabush choice :none then :auto

The trail watch at the Duckabush elk ford first answers without reading
the staff, then opens the tools and posts 2.4 ft on the wapiti trail.

**What it teaches**

- `choice: :none` keeps `elk_ford_depth` registered and sends
  `"tool_choice":"none"`. The first ask has no `:tool` message.
- `choice: :auto` opens the tools again. The second ask reads 2.4 ft.
- `with_tools` is not cleared. RubyLLM 2.1.1 has no `with_params`;
  `with_tool_options` is the knob.

**Files**

| File | Role |
| --- | --- |
| [`elk_ford.rb`](elk_ford.rb) | Closes the staff, then opens it |
| [`elk_ford_test.rb`](elk_ford_test.rb) | Replays the cassette |
| [`cassettes/elk_ford.yml`](cassettes/elk_ford.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/05-duckabush-choice-none-then-auto/elk_ford_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/05-duckabush-choice-none-then-auto/elk_ford_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
