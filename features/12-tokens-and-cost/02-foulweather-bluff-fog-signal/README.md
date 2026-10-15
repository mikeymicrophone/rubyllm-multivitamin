# Tokens and cost · 02 · Foulweather Bluff fog-signal zero

The keeper at Foulweather Bluff Light, north of Hood Canal, speaks the
posted 4-second blast for the tender Osprey standing in toward Twin
Spits. The free OpenRouter slug reports `usage.cost` 0, and `cost.total`
is that zero, not a missing price.

**What it teaches**

- A free slug reports `usage.cost` `0`.
- `cost.total` equals that reported zero. It is not `nil`.
- A missing registry price would have left `cost.total` nil. A reported
  zero stays zero.

**Files**

| File | Role |
| --- | --- |
| [`fog_signal_cost.rb`](fog_signal_cost.rb) | Asks the fog-signal pattern and returns the cost |
| [`fog_signal_cost_test.rb`](fog_signal_cost_test.rb) | Replays the cassette and checks the reported zero |
| [`cassettes/fog_signal_cost.yml`](cassettes/fog_signal_cost.yml) | The Chat Completions round-trip |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/02-foulweather-bluff-fog-signal/fog_signal_cost.rb
bundle exec ruby features/12-tokens-and-cost/02-foulweather-bluff-fog-signal/fog_signal_cost_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/02-foulweather-bluff-fog-signal/fog_signal_cost.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 15 October 2026.
