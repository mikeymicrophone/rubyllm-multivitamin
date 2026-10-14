# Instructions and history · 10 · Neah Bay seeded ladder card

The relief at Neah Bay walks in with last watch's boarding-ladder card
already written: 8 steps and 2.0 m freeboard. Those two turns are seeded
with `add_message`. Calder's recount then corrects the card to 9 steps
and 2.2 m.

**What it teaches**

- `add_message` seeds a prior user and assistant turn with no HTTP call.
- The next `ask` sends those seeded turns on the wire. The cassette has
  one round-trip.
- The correction is a user turn. The following answer uses 9 and 2.2.

**Files**

| File | Role |
| --- | --- |
| [`seeded_ladder.rb`](seeded_ladder.rb) | Seeds last watch, then asks Calder's recount |
| [`seeded_ladder_test.rb`](seeded_ladder_test.rb) | Replays the cassette and checks the one request |
| [`cassettes/seeded_ladder.yml`](cassettes/seeded_ladder.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/10-neah-bay-seeded-ladder/seeded_ladder.rb
bundle exec ruby features/11-instructions-and-history/10-neah-bay-seeded-ladder/seeded_ladder_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/10-neah-bay-seeded-ladder/seeded_ladder.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
