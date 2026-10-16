# Evaluations · 02 · Chiang Rai miang-leaf structured inputs

The leaf clerk at the Chiang Rai miang yard reads lot CR-18 from a structured
case. `inputs` is a Hash of lot, grade, and question, not a single string.

**What it teaches**

- Dataset `inputs` may be a Hash. `perform` receives that Hash.
- The clerk builds the posted card from those keys.
- `expected_output` still grades meaning.

**Files**

| File | Role |
| --- | --- |
| [`miang_leaf.rb`](miang_leaf.rb) | Runs the structured rack-count case |
| [`miang_leaf.yml`](miang_leaf.yml) | Lot CR-18 as a Hash |
| [`miang_leaf_test.rb`](miang_leaf_test.rb) | Replays the cassette and checks the Hash keys |
| [`cassettes/miang_leaf.yml`](cassettes/miang_leaf.yml) | Clerk and grader round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/02-chiang-rai-miang-leaf/miang_leaf.rb
bundle exec ruby features/20-evaluations/02-chiang-rai-miang-leaf/miang_leaf_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/02-chiang-rai-miang-leaf/miang_leaf.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Fallback: `LIVE_PROVIDER=openrouter` records `nvidia/nemotron-3-super-120b-a12b:free` for the clerk when the daily cap allows; the grader stays on OpenAI because it needs structured output. Checked 16 October 2026.
