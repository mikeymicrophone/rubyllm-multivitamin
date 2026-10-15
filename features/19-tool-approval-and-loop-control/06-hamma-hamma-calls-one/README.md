# Tool approval and loop control · 06 · Hamma Hamma calls: :one

The falls watch on the Hamma Hamma wants the upper lip and the lower
plunge pool. `calls: :one` lets one assistant turn carry only a single
gauge. The loop may still read the other reach on a later turn.

**What it teaches**

- `calls: :one` sends `"parallel_tool_calls":false`. The first assistant
  turn has one `falls_gauge` call.
- The cap is per response, not per conversation. `ask` continues until
  both 2.1 ft and 5.4 ft are on the transcript.
- `calls: :many` is the opposite knob, already bottled on the Port
  Townsend slip anemometers.

**Files**

| File | Role |
| --- | --- |
| [`falls_gauge.rb`](falls_gauge.rb) | Caps each turn at one reach |
| [`falls_gauge_test.rb`](falls_gauge_test.rb) | Replays the cassette |
| [`cassettes/falls_gauge.yml`](cassettes/falls_gauge.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/06-hamma-hamma-calls-one/falls_gauge_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/06-hamma-hamma-calls-one/falls_gauge_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
