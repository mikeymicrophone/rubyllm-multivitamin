# Evaluations · 10 · Recife frevo-ribbon expected versus output

The ribbon clerk at the Recife frevo loft files 36 ribbons for Moacir.
`evaluator false` grades with Ruby assertions against `expected_output`.

**What it teaches**

- `evaluator false` skips the chat grader and runs only Ruby assertions.
- `assertions` can compare `output` to `expected_output` on the same instance.
- `trial.output` is the spoken answer; `trial.test_case.expected_output` is the card.

**Files**

| File | Role |
| --- | --- |
| [`frevo_ribbon.rb`](frevo_ribbon.rb) | Runs the ribbon case with assertions-only grading |
| [`frevo_ribbon.yml`](frevo_ribbon.yml) | The ribbon-count case |
| [`frevo_ribbon_test.rb`](frevo_ribbon_test.rb) | Replays the cassette and checks assertion_count |
| [`cassettes/frevo_ribbon.yml`](cassettes/frevo_ribbon.yml) | The clerk Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/10-recife-frevo-ribbon/frevo_ribbon.rb
bundle exec ruby features/20-evaluations/10-recife-frevo-ribbon/frevo_ribbon_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/10-recife-frevo-ribbon/frevo_ribbon.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk. There is no grader call. Checked 16 October 2026.
