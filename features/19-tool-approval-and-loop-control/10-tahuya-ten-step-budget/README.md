# Tool approval and loop control · 10 · Tahuya ten-step budget

The sounding watch at Tahuya spit would keep calling the pole out to
mark 20. A ten-step budget stops the loop after five soundings. The
transcript is still valid. One more `step` resumes where it stopped.

**What it teaches**

- Cap a runaway tool loop with a step budget, not by raising inside
  `before_tool_call`.
- Ten `step`s are five generates and five `run_tools` moves, so the pole
  has been sounded five times. `complete?` is false.
- Calling `step` again continues. The sixth mark lands on the transcript
  without restaging the question.

**Files**

| File | Role |
| --- | --- |
| [`sounding_pole.rb`](sounding_pole.rb) | Walks ten steps, then one more |
| [`sounding_pole_test.rb`](sounding_pole_test.rb) | Replays the cassette |
| [`cassettes/sounding_pole.yml`](cassettes/sounding_pole.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/19-tool-approval-and-loop-control/10-tahuya-ten-step-budget/sounding_pole_test.rb
```

The test replays the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/19-tool-approval-and-loop-control/10-tahuya-ten-step-budget/sounding_pole_test.rb
```

`LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` instead and overwrites this cassette. The helper strips `Authorization` and `OPENAI_API_KEY` before the file is written. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai`. The id was on OpenAI's models list on 14 October 2026. It advertises function calling, `tool_choice`, parallel tool calls, and temperature. OpenRouter's free chat model remains the alternative for a re-record: `nvidia/nemotron-3-super-120b-a12b:free`, then `liquid/lfm-2.5-2.6b:free`.
