# Streaming · 07 · Bellingham cold storage chant

The auctioneer at Bellingham Cold Storage chants four lots off the dock
sheet: Alden, Retort, Kelp, and Ledge. The chant is long enough that the
block runs more than once. The clerk writes each piece to a tape, and the
office pulls the same pieces from an Enumerator.

**What it teaches**

- A long reply yields many chunks. The block runs once per chunk.
- `write` on any IO receives the spoken pieces in order. A `StringIO` stands
  in for the tape; a `File` would take the same `write` calls.
- `each_bid` returns an Enumerator when no block is given. The HTTP call
  starts when the Enumerator is pulled. `to_a` is the joined chant.

**Files**

| File | Role |
| --- | --- |
| [`auction_chant.rb`](auction_chant.rb) | Streams the chant onto an IO through an Enumerator |
| [`auction_chant_test.rb`](auction_chant_test.rb) | Replays the cassette and pulls the Enumerator |
| [`cassettes/auction_chant.yml`](cassettes/auction_chant.yml) | The streamed chant |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/02-streaming/07-bellingham-cold-storage-chant/auction_chant.rb
bundle exec ruby features/02-streaming/07-bellingham-cold-storage-chant/auction_chant_test.rb
```

Both commands replay the cassette. No API key is required. Re-record it
with:

```sh
LIVE=1 OPENROUTER_API_KEY=... bundle exec ruby features/02-streaming/07-bellingham-cold-storage-chant/auction_chant_test.rb
```

**Model**

`nvidia/nemotron-3-super-120b-a12b:free` on OpenRouter. Fallback if that slug
is gone: `liquid/lfm-2.5-2.6b:free`. Checked 14 October 2026.
