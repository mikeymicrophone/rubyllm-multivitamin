# Tool approval and loop control · 13 · Bangor horn latch capstone

The duty officer at Bangor reads the outbound range and sounds the Hood
Canal horn for the USS Kentucky. The range card runs at once. The horn
waits on the latch. A follow-up after approval still has 07:40 and the
4 second blast.

**What it teaches**

- An unprotected tool still executes while a protected call waits.
  `pending_approvals` lists only `sound_the_horn`.
- `ask` while that call is pending raises `PendingToolCallsError`.
- `approve` then `complete` sounds the horn. `execute` receives the
  `ToolCall` on the reserved `tool_call:` keyword.
- `restricted_gate_log` stays registered and is not called. A later ask
  with `choice: :none` sends both tool results back without a new call.

**Files**

| File | Role |
| --- | --- |
| [`horn_latch.rb`](horn_latch.rb) | Mixes a free card with a latched horn, then follows up |
| [`horn_latch_test.rb`](horn_latch_test.rb) | Replays the cassette |
| [`cassettes/horn_latch.yml`](cassettes/horn_latch.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/13-bangor-horn-latch-capstone/horn_latch_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/13-bangor-horn-latch-capstone/horn_latch_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
