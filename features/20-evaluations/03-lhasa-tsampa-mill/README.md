# Evaluations · 03 · Lhasa tsampa-mill multi-turn

The mill clerk logs 1,080 tsampa sacks, then answers whether Tenzin may send
extra millers through the yard gate before 09:15. `perform` returns the Chat.

**What it teaches**

- `perform` may run two `ask`s and return the `Chat`.
- The grader sees every message, not only the last sentence.
- `trial.result.messages` keeps the five-role transcript. `trial.output` is the last turn.

**Files**

| File | Role |
| --- | --- |
| [`tsampa_mill.rb`](tsampa_mill.rb) | Asks the count, then the gate, and returns the chat |
| [`tsampa_mill.yml`](tsampa_mill.yml) | Opening and follow-up as structured inputs |
| [`tsampa_mill_test.rb`](tsampa_mill_test.rb) | Replays the cassette and checks the roles |
| [`cassettes/tsampa_mill.yml`](cassettes/tsampa_mill.yml) | Two clerk turns and one grader turn |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/03-lhasa-tsampa-mill/tsampa_mill.rb
bundle exec ruby features/20-evaluations/03-lhasa-tsampa-mill/tsampa_mill_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/03-lhasa-tsampa-mill/tsampa_mill.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Fallback: `LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` for the clerk when the daily cap allows; the grader stays on OpenAI because it needs structured output. Checked 16 October 2026.
