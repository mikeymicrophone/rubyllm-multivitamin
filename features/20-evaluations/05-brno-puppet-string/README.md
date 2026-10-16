# Evaluations · 05 · Brno puppet-string custom evaluator

The string clerk at the Brno puppet loft files marionette B-7. A custom
criterion checks that the answer names Eliska, beside built-in correctness.

**What it teaches**

- `evaluation :names_the_bar` declares a second semantic criterion.
- Declared criteria replace implicit correctness unless `:correctness` is named.
- Both verdicts must pass for `report.passed?`.

**Files**

| File | Role |
| --- | --- |
| [`puppet_string.rb`](puppet_string.rb) | Declares two criteria and runs the loft case |
| [`puppet_string.yml`](puppet_string.yml) | The string-count case |
| [`puppet_string_test.rb`](puppet_string_test.rb) | Replays the cassette and checks both names |
| [`cassettes/puppet_string.yml`](cassettes/puppet_string.yml) | Clerk and two-criterion grader |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/05-brno-puppet-string/puppet_string.rb
bundle exec ruby features/20-evaluations/05-brno-puppet-string/puppet_string_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/05-brno-puppet-string/puppet_string.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
