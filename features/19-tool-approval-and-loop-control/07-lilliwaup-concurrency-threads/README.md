# Tool approval and loop control · 07 · Lilliwaup concurrency threads

The mill watch at Lilliwaup reads the county creek stage and the hemlock
boom pocket in one assistant turn. `concurrency: :threads` runs those
two I/O-bound tools on Ruby threads.

**What it teaches**

- `calls: :many` sends `"parallel_tool_calls":true` so one turn can
  carry `creek_stage` and `boom_log`.
- `concurrency: :threads` (or `true`) runs them on threads. The two
  `Thread.current.object_id` values differ. Results join the transcript
  as each call finishes. The creek sleep is shorter than the boom sleep
  so the second request body stays stable on replay.
- `3.8 ft` and `42 sticks` are only on the tools. The spoken answer
  repeats both.

**Files**

| File | Role |
| --- | --- |
| [`creek_and_boom.rb`](creek_and_boom.rb) | Calls both tools on threads |
| [`creek_and_boom_test.rb`](creek_and_boom_test.rb) | Replays the cassette |
| [`cassettes/creek_and_boom.yml`](cassettes/creek_and_boom.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/07-lilliwaup-concurrency-threads/creek_and_boom_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/07-lilliwaup-concurrency-threads/creek_and_boom_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
