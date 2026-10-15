# Tool approval and loop control · 02 · Dabob Bay deny the charge

The range officer on Dabob Bay will not fire a 2 lb SUS hydrophone charge
at buoy DB-7. `fire_range_charge` requires approval. `deny` then
`complete` appends a structured error and the model reports that the
charge was not fired.

**What it teaches**

- `deny` records a refusal. `execute` never runs.
- The tool message is JSON: `{ "error": "The user denied the fire_range_charge tool call." }`.
- `complete` asks the model to continue from that denial. The spoken
  answer names buoy DB-7 and does not claim a blast.

**Files**

| File | Role |
| --- | --- |
| [`deny_charge.rb`](deny_charge.rb) | Parks the charge, then denies it |
| [`deny_charge_test.rb`](deny_charge_test.rb) | Replays the cassette |
| [`cassettes/deny_charge.yml`](cassettes/deny_charge.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/02-dabob-bay-deny-charge/deny_charge_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/02-dabob-bay-deny-charge/deny_charge_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
