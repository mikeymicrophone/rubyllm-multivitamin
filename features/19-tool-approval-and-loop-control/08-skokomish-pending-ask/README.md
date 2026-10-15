# Tool approval and loop control · 08 · Skokomish pending ask raises

The river tender at the Skokomish estuary parks the tide-gate latch.
A second `ask` from the Annas Bay skiff raises before any new HTTP call.
`approve` then `complete` opens the gate on a 2.2 kn ebb.

**What it teaches**

- `ask` (via `ask_later`) raises `RubyLLM::PendingToolCallsError` while
  a tool call is unanswered. The message names `estuary_latch` and tells
  you to `complete` after `approve` or `deny`.
- That class inherits `StandardError`. It does not inherit
  `RubyLLM::Error`. A rescue of provider errors misses it.
- The second question is never staged. After approval the original
  round finishes and the answer names 2.2 kn and the Highway 101 twin
  bridges.

**Files**

| File | Role |
| --- | --- |
| [`estuary_latch.rb`](estuary_latch.rb) | Parks the gate, raises, then approves |
| [`estuary_latch_test.rb`](estuary_latch_test.rb) | Replays the cassette |
| [`cassettes/estuary_latch.yml`](cassettes/estuary_latch.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/08-skokomish-pending-ask/estuary_latch_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/08-skokomish-pending-ask/estuary_latch_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
