# Evaluations · 08 · Mopti banco-brick Rake task

The brick clerk on the west wall at Mopti files 64 banco bricks for Aissata.
The class lives under `app/evals`, the same place `ruby_llm:eval` discovers.

**What it teaches**

- `app/evals/*_evaluation.rb` is the file the Rake task loads.
- `Evaluation.run.save` writes the JSON report the task would print.
- The task exits unsuccessfully when any case fails; this case passes.

**Files**

| File | Role |
| --- | --- |
| [`banco_brick.rb`](banco_brick.rb) | Runs the eval desk and writes the JSON report |
| [`app/evals/mopti_brick_evaluation.rb`](app/evals/mopti_brick_evaluation.rb) | The discovered evaluation class |
| [`app/evals/mopti_brick_evaluation.yml`](app/evals/mopti_brick_evaluation.yml) | The brick-count case |
| [`banco_brick_test.rb`](banco_brick_test.rb) | Replays the cassette and reads the saved report |
| [`cassettes/banco_brick.yml`](cassettes/banco_brick.yml) | Clerk and grader round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/08-mopti-banco-brick/banco_brick.rb
bundle exec ruby features/20-evaluations/08-mopti-banco-brick/banco_brick_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/08-mopti-banco-brick/banco_brick.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
