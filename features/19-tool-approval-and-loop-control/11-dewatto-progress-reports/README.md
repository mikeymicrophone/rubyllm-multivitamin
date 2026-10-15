# Tool approval and loop control · 11 · Dewatto progress reports

The boom clerk on the Dewatto reach counts four log booms before posting
186 sticks. Each boom reports progress. The callbacks see the arguments,
the Progress objects, and the final card.

**What it teaches**

- `progress` inside `execute` reports `value:` and `total:`.
  `Progress#fraction` is the share done.
- `after_tool_progress` receives the tool call and each `RubyLLM::Progress`.
- `before_tool_call` receives the arguments Hash. `after_tool_result`
  receives the Ruby return, which is still a String here, not JSON.

**Files**

| File | Role |
| --- | --- |
| [`log_boom.rb`](log_boom.rb) | Counts four booms and reports each one |
| [`log_boom_test.rb`](log_boom_test.rb) | Replays the cassette |
| [`cassettes/log_boom.yml`](cassettes/log_boom.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/11-dewatto-progress-reports/log_boom_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/11-dewatto-progress-reports/log_boom_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
