# Tokens and cost · 05 · Point No Point current-gate cap

The current clerk at Point No Point Light copies the Admiralty Inlet
table for the kelp skiff Hansville, then tries to post the note under a
64-token output budget. The watch reads `max_tokens?` and the output
count, not only the spoken words.

**What it teaches**

- `with_max_output_tokens` is a token budget on the reply. The wire field
  on OpenRouter is `max_tokens`.
- A tight cap can finish with `max_tokens?` true and `finish_reason`
  `:max_tokens`.
- `tokens.output` still reports the tokens used under that cap. On this
  recording it equals the budget.

**Files**

| File | Role |
| --- | --- |
| [`current_gate.rb`](current_gate.rb) | Asks the current table under a 64-token cap |
| [`current_gate_test.rb`](current_gate_test.rb) | Replays the cassette and checks the finish reason |
| [`cassettes/current_gate.yml`](cassettes/current_gate.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/05-point-no-point-current-gate/current_gate.rb
bundle exec ruby features/12-tokens-and-cost/05-point-no-point-current-gate/current_gate_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/05-point-no-point-current-gate/current_gate.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
