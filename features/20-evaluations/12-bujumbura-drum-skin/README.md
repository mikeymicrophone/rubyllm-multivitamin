# Evaluations · 12 · Bujumbura drum-skin failing case

The skin clerk at the Bujumbura drum loft reads a mis-posted card of 18
skins. The expected card still lists 14, so correctness fails.

**What it teaches**

- A trial fails when the spoken answer disagrees with `expected_output`.
- `report.passed?` is false when any trial fails.
- The fail reason sits on the `:correctness` evaluation.

**Files**

| File | Role |
| --- | --- |
| [`drum_skin.rb`](drum_skin.rb) | Runs the mis-posted skin-count case |
| [`drum_skin.yml`](drum_skin.yml) | The expected 14-skin card |
| [`drum_skin_test.rb`](drum_skin_test.rb) | Replays the cassette and checks the failure |
| [`cassettes/drum_skin.yml`](cassettes/drum_skin.yml) | Clerk and failing grader |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/12-bujumbura-drum-skin/drum_skin.rb
bundle exec ruby features/20-evaluations/12-bujumbura-drum-skin/drum_skin_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/12-bujumbura-drum-skin/drum_skin.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
