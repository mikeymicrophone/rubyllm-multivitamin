# Tokens and cost · 02 · Ouarzazate kasbah flicker zero

The flicker clerk on the kasbah night set at Ouarzazate speaks the posted
4-second lamp pattern for the grip cart standing in toward Ait Benhaddou.
The free OpenRouter slug reports `usage.cost` 0, and `cost.total` is that
zero, not a missing price.

**What it teaches**

- A free slug reports `usage.cost` `0`.
- `cost.total` equals that reported zero. It is not `nil`.
- A missing registry price would have left `cost.total` nil. A reported
  zero stays zero.

**Files**

| File | Role |
| --- | --- |
| [`flicker_cost.rb`](flicker_cost.rb) | Asks the lamp pattern and returns the cost |
| [`flicker_cost_test.rb`](flicker_cost_test.rb) | Replays the cassette and checks the reported zero |
| [`cassettes/flicker_cost.yml`](cassettes/flicker_cost.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/02-ouarzazate-flicker-zero/flicker_cost.rb
bundle exec ruby features/12-tokens-and-cost/02-ouarzazate-flicker-zero/flicker_cost_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/02-ouarzazate-flicker-zero/flicker_cost.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
