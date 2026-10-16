# Instructions and history · 10 · Trondheim seeded bellows card

The relief at Nidaros Cathedral walks in with last watch's organ-bellows
card already written: 8 folds and 2.0 kPa wind. Those two turns are
seeded with `add_message`. Sigrid's recount then corrects the card to 9
folds and 2.2 kPa.

**What it teaches**

- `add_message` seeds a prior user and assistant turn with no HTTP call.
- The next `ask` sends those seeded turns on the wire. The cassette has
  one round-trip.
- The correction is a user turn. The following answer uses 9 and 2.2.

**Files**

| File | Role |
| --- | --- |
| [`seeded_bellows.rb`](seeded_bellows.rb) | Seeds last watch, then asks Sigrid's recount |
| [`seeded_bellows_test.rb`](seeded_bellows_test.rb) | Replays the cassette and checks the one request |
| [`cassettes/seeded_bellows.yml`](cassettes/seeded_bellows.yml) | Live recording of the correction ask |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/10-trondheim-bellows-seed/seeded_bellows.rb
bundle exec ruby features/11-instructions-and-history/10-trondheim-bellows-seed/seeded_bellows_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/10-trondheim-bellows-seed/seeded_bellows.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
