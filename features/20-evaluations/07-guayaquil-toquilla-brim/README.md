# Evaluations · 07 · Guayaquil toquilla-brim Minitest helper

The brim clerk at the Guayaquil toquilla loft files hat TQ-4. Extending
`RubyLLM::Evaluation::Minitest` adds one test method per dataset case.

**What it teaches**

- `extend RubyLLM::Evaluation::Minitest` then `evaluates` adds one test per case.
- The helper uses the same runner as `Evaluation.run`.
- This slot also runs the case through `conduct` so the cassette stays one file.

**Files**

| File | Role |
| --- | --- |
| [`toquilla_brim.rb`](toquilla_brim.rb) | Runs the brim case |
| [`toquilla_brim.yml`](toquilla_brim.yml) | The brim-width case |
| [`toquilla_brim_test.rb`](toquilla_brim_test.rb) | Checks the helper methods and the graded case |
| [`cassettes/toquilla_brim.yml`](cassettes/toquilla_brim.yml) | Clerk and grader round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/07-guayaquil-toquilla-brim/toquilla_brim.rb
bundle exec ruby features/20-evaluations/07-guayaquil-toquilla-brim/toquilla_brim_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/07-guayaquil-toquilla-brim/toquilla_brim.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
