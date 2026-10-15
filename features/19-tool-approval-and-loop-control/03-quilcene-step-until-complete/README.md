# Tool approval and loop control · 03 · Quilcene step until complete?

The oyster clerk at Quilcene Bay stages the question, then walks the loop
one move at a time until the Linger Longer beds can be walked at 08:10.

**What it teaches**

- `ask_later` stages the user turn. `complete?` is then false.
- `step` generates, then runs the staff, then generates the speech.
  `step until complete? || waiting?` is the loop `ask` would have run.
- A further `step` returns `nil`. `waiting?` is false because this tool
  does not need approval.

**Files**

| File | Role |
| --- | --- |
| [`oyster_staff.rb`](oyster_staff.rb) | Stages the question and steps the staff |
| [`oyster_staff_test.rb`](oyster_staff_test.rb) | Replays the cassette |
| [`cassettes/oyster_staff.yml`](cassettes/oyster_staff.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/03-quilcene-step-until-complete/oyster_staff_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/03-quilcene-step-until-complete/oyster_staff_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
