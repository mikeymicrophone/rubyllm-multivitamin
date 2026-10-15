# Tokens and cost · 07 · Ballard Locks salmon-count reported price

The fish-count clerk at the Hiram M. Chittenden Locks files the morning
sockeye window on ladder 1. OpenRouter reports `usage.cost`. That number
is `cost.total`. The same token work, stripped of the reported price and
run through `gpt-4.1-mini`'s registry rates, is a non-zero estimate.

**What it teaches**

- When the provider reports a price, `cost.total` is that amount, not a
  registry estimate.
- Component readers such as `cost.input` still use the registry. This
  assumed free slug has no prices, so those stay `nil` while total is `0`.
- `model.cost_for` keeps `tokens.reported_cost` when it is present. A
  `Tokens` built with only input and output lets the registry price the
  work. An unlisted assumed model then yields `nil`.

**Files**

| File | Role |
| --- | --- |
| [`salmon_count.rb`](salmon_count.rb) | Asks the ladder count and prices the tokens two ways |
| [`salmon_count_test.rb`](salmon_count_test.rb) | Replays the cassette and checks reported versus registry |
| [`cassettes/salmon_count.yml`](cassettes/salmon_count.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/07-ballard-locks-salmon-count/salmon_count.rb
bundle exec ruby features/12-tokens-and-cost/07-ballard-locks-salmon-count/salmon_count_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/07-ballard-locks-salmon-count/salmon_count.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. The registry
comparison uses bundled `gpt-4.1-mini` prices and does not open a second
socket. Fallback if the free slug is gone: `liquid/lfm-2.5-2.6b:free`.
Checked 15 October 2026.
