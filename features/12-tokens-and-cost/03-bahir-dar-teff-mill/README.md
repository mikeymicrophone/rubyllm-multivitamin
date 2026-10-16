# Tokens and cost · 03 · Bahir Dar teff-mill totals

The mill clerk at the Bahir Dar lakeshore mill logs the morning teff
sack count, then answers whether the cart Tana may send extra weighers
through the yard gate before 09:00. Both questions sit on one chat.
`chat.tokens` sums the attempts.

**What it teaches**

- `chat.tokens` aggregates every provider attempt on that chat.
- With `max_retries` 0 and two successful asks, `chat.tokens.input`
  equals the sum of the two replies' input counts.
- The second ask sends the first turn back, so its input is larger.

**Files**

| File | Role |
| --- | --- |
| [`teff_mill.rb`](teff_mill.rb) | Asks the count, then the gate, and returns the sums |
| [`teff_mill_test.rb`](teff_mill_test.rb) | Replays the cassette and checks the totals |
| [`cassettes/teff_mill.yml`](cassettes/teff_mill.yml) | The two Chat Completions round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/12-tokens-and-cost/03-bahir-dar-teff-mill/teff_mill.rb
bundle exec ruby features/12-tokens-and-cost/03-bahir-dar-teff-mill/teff_mill_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/12-tokens-and-cost/03-bahir-dar-teff-mill/teff_mill.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 16 October 2026.
