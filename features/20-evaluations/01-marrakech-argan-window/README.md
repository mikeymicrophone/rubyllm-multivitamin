# Evaluations · 01 · Marrakech argan return window

The press clerk in the Mellah answers two return questions from the posted
argan card: an unopened tin within 30 days, and a market-day tin that stays
final. `ReturnWindow.run` grades both cases.

**What it teaches**

- A `RubyLLM::Evaluation` subclass implements `perform(input)`.
- A YAML dataset lists `name`, `inputs`, and `expected_output`.
- `run` returns a report. `passed?` is true when every case matches.
- The default criterion is `:correctness`. Different wording still passes.

**Files**

| File | Role |
| --- | --- |
| [`argan_window.rb`](argan_window.rb) | Runs the two return cases and prints the report |
| [`argan_window.yml`](argan_window.yml) | The unopened-tin and market-day cases |
| [`argan_window_test.rb`](argan_window_test.rb) | Replays the cassette and checks passed? |
| [`cassettes/argan_window.yml`](cassettes/argan_window.yml) | Clerk and grader Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/01-marrakech-argan-window/argan_window.rb
bundle exec ruby features/20-evaluations/01-marrakech-argan-window/argan_window_test.rb
```

Both commands replay the cassette. No API key is required. `rake test` runs
the same test with the rest of the bottled examples.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/01-marrakech-argan-window/argan_window.rb
```

`LIVE=1` overwrites the cassette. The helper strips `Authorization` and any
`sk-` token before the file is written.

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Fallback: `LIVE_PROVIDER=openrouter` records
`nvidia/nemotron-3-super-120b-a12b:free` for the clerk when the daily cap
allows; the grader stays on OpenAI because it needs structured output.
Checked 16 October 2026.
