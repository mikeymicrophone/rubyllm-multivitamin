# Evaluations · 06 · Tabriz carpet-knot Judge grader

The knot clerk at the Tabriz loft files 86 knots for Farhad. A Judge, not
the chat reviewer, grades whether the answer agrees with the card.

**What it teaches**

- `evaluator` may be a `RubyLLM::Judge` class.
- `evaluation :agrees, minimum: 0.5` turns a probability into a pass.
- Without a minimum, a numeric decision is only `:measured`.

**Files**

| File | Role |
| --- | --- |
| [`carpet_knot.rb`](carpet_knot.rb) | Asks the loom card and grades it with a Judge |
| [`carpet_knot.yml`](carpet_knot.yml) | The knot-count case |
| [`carpet_knot_test.rb`](carpet_knot_test.rb) | Replays the cassette and checks :agrees |
| [`cassettes/carpet_knot.yml`](cassettes/carpet_knot.yml) | Clerk chat and Decisions judgment |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/06-tabriz-carpet-knot/carpet_knot.rb
bundle exec ruby features/20-evaluations/06-tabriz-carpet-knot/carpet_knot_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/06-tabriz-carpet-knot/carpet_knot.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk. The Judge posts to OpenAI Decisions on `gpt-6-luna`. `LIVE_PROVIDER` does not retarget the Judge. Checked 16 October 2026.
