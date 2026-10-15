# Streaming · 07 · Ulaanbaatar cashmere chant

The auctioneer at the Gobi cashmere hall in Ulaanbaatar chants four lots
off the sheet: Altai, Khan, Steppe, and Ger. The chant is long enough that
the block runs more than once. The clerk writes each piece to a tape, and
the office pulls the same pieces from an Enumerator.

**What it teaches**

- A long reply yields many chunks. The block runs once per chunk.
- `write` on any IO receives the spoken pieces in order. A `StringIO` stands
  in for the tape; a `File` would take the same `write` calls.
- `each_bid` returns an Enumerator when no block is given. The HTTP call
  starts when the Enumerator is pulled. `to_a` is the joined chant.

**Files**

| File | Role |
| --- | --- |
| [`cashmere_chant.rb`](cashmere_chant.rb) | Streams the chant onto an IO through an Enumerator |
| [`cashmere_chant_test.rb`](cashmere_chant_test.rb) | Replays the cassette and pulls the Enumerator |
| [`cassettes/cashmere_chant.yml`](cassettes/cashmere_chant.yml) | The streamed chant |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/07-ulaanbaatar-cashmere-chant/cashmere_chant.rb
bundle exec ruby features/02-streaming/07-ulaanbaatar-cashmere-chant/cashmere_chant_test.rb
```

Both commands replay the cassette. No API key is required. Re-record it
with:

```sh
LIVE=1 OPENAI_API_KEY=... bundle exec ruby features/02-streaming/07-ulaanbaatar-cashmere-chant/cashmere_chant_test.rb
```

**Model**

`gpt-4.1-mini` on OpenAI (`provider: :openai`). Recorded after OpenRouter
`:free` slugs hit `free-models-per-day` on 15 October 2026. Fallback:
`gpt-4o-mini`. Re-record on the free slug with `LIVE_PROVIDER=openrouter`.
