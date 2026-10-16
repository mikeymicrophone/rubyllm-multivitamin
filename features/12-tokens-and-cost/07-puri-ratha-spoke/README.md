# Tokens and cost · 07 · Puri ratha-spoke reported price

The spoke clerk at the Puri ratha yard files the morning count on ratha
1. OpenRouter reports `usage.cost`. That number is `cost.total`. The
same token work, stripped of the reported price and run through
`gpt-4.1-mini`'s registry rates, is a non-zero estimate.

**What it teaches**

- When the provider reports a price, `cost.total` is that amount, not a
  registry estimate.
- Component readers such as `cost.input` still use the registry. This
  `:free` slug is in the bundled catalog at `$0` per million tokens, so
  those components are `0.0` while `cost.total` is the reported `0`.
- `model.cost_for` keeps `tokens.reported_cost` when it is present. A
  `Tokens` built with only input and output lets the registry price the
  work. `RubyLLM::Model.default` for an unlisted clerk then yields `nil`.

**Files**

| File | Role |
| --- | --- |
| [`ratha_count.rb`](ratha_count.rb) | Asks the spoke count and prices the tokens two ways |
| [`ratha_count_test.rb`](ratha_count_test.rb) | Replays the cassette and checks reported versus registry |
| [`cassettes/ratha_count.yml`](cassettes/ratha_count.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/07-puri-ratha-spoke/ratha_count.rb
bundle exec ruby features/12-tokens-and-cost/07-puri-ratha-spoke/ratha_count_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/07-puri-ratha-spoke/ratha_count.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. The registry
comparison uses bundled `gpt-4.1-mini` prices and does not open a second
socket. Fallback if the free slug is gone: `liquid/lfm-2.5-2.6b:free`.
Checked 16 October 2026.
