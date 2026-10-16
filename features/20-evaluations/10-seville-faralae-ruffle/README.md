# Evaluations · 10 · Seville faralae-ruffle expected versus output

The ruffle clerk at the Seville faralae loft files 36 ruffles for Rafaela.
`evaluator false` grades with Ruby assertions against `expected_output`.

**What it teaches**

- `evaluator false` skips the chat grader and runs only Ruby assertions.
- `assertions` can compare `output` to `expected_output` on the same instance.
- `trial.output` is the spoken answer; `trial.test_case.expected_output` is the card.

**Files**

| File | Role |
| --- | --- |
| [`faralae_ruffle.rb`](faralae_ruffle.rb) | Runs the ruffle case with assertions-only grading |
| [`faralae_ruffle.yml`](faralae_ruffle.yml) | The ruffle-count case |
| [`faralae_ruffle_test.rb`](faralae_ruffle_test.rb) | Replays the cassette and checks assertion_count |
| [`cassettes/faralae_ruffle.yml`](cassettes/faralae_ruffle.yml) | The clerk Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/10-seville-faralae-ruffle/faralae_ruffle.rb
bundle exec ruby features/20-evaluations/10-seville-faralae-ruffle/faralae_ruffle_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/10-seville-faralae-ruffle/faralae_ruffle.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk. There is no grader call. Checked 16 October 2026.
