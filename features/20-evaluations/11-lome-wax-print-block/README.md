# Evaluations · 11 · Lomé wax-print progress callback

The block clerk at the Lomé wax-print yard files 11 blocks for Afi. `run`
yields each finished trial before the next case starts.

**What it teaches**

- `Evaluation.run` yields each completed `Trial` before the next case starts.
- The block sees `trial.test_case.name` in dataset order.
- Exceptions from the block propagate and stop the run.

**Files**

| File | Role |
| --- | --- |
| [`wax_print_block.rb`](wax_print_block.rb) | Runs two cases and records the progress names |
| [`wax_print_block.yml`](wax_print_block.yml) | The block-count and stamp-clerk cases |
| [`wax_print_block_test.rb`](wax_print_block_test.rb) | Replays the cassette and checks the order |
| [`cassettes/wax_print_block.yml`](cassettes/wax_print_block.yml) | Two clerk turns and two grader turns |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/20-evaluations/11-lome-wax-print-block/wax_print_block.rb
bundle exec ruby features/20-evaluations/11-lome-wax-print-block/wax_print_block_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/20-evaluations/11-lome-wax-print-block/wax_print_block.rb
```

**Model**

OpenAI `gpt-4.1-mini` for the clerk and the grader. Checked 16 October 2026.
