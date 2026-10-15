# Tokens and cost · 13 · Haro Strait watch ledger

The overnight desk on Haro Strait files a Turn Point flood brief, then
answers whether the tanker Polar Adventure may start north before slack.
The ledger prints per-turn and chat totals. The same token work is then
priced on two registry models against a one-cent watch budget.

**What it teaches**

- A ledger is just `tokens` and `cost` on each message, plus `chat.tokens`
  and `chat.cost` for the conversation.
- `model.cost_for` estimates the same token work at registry rates.
  `gpt-4o-mini` is cheaper than `gpt-4.1-mini` for this payload.
- A watch budget is compared to those estimates. The free slug's
  reported `cost.total` of `0` is not the figure that budget is for.

**Files**

| File | Role |
| --- | --- |
| [`watch_ledger.rb`](watch_ledger.rb) | Asks both watch questions, prints the ledger, and prices two models |
| [`watch_ledger_test.rb`](watch_ledger_test.rb) | Replays the cassette and checks the ledger and the cheaper clerk |
| [`cassettes/watch_ledger.yml`](cassettes/watch_ledger.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/13-haro-strait-watch-ledger/watch_ledger.rb
bundle exec ruby features/12-tokens-and-cost/13-haro-strait-watch-ledger/watch_ledger_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/13-haro-strait-watch-ledger/watch_ledger.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter for the two watch
turns. The comparison uses bundled `gpt-4.1-mini` and `gpt-4o-mini`
prices and does not open a second socket. Fallback if the free slug is
gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
