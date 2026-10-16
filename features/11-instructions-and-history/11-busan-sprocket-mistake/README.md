# Instructions and history · 11 · Busan sprocket mistake left in

Last watch at a Haeundae 35 mm lab posted the rear sprocket as 6 frames.
The card says 2.5. The clerk leaves that assistant turn on the
transcript and asks only for the front interval.

**What it teaches**

- An earlier assistant mistake can stay in `chat.messages` on purpose.
- The next request still carries `6 frames`.
- The follow-up can still read the front interval, 4 frames, off the
  card.

**Files**

| File | Role |
| --- | --- |
| [`sprocket_mistake.rb`](sprocket_mistake.rb) | Seeds the wrong rear interval, then asks the front |
| [`sprocket_mistake_test.rb`](sprocket_mistake_test.rb) | Replays the cassette and checks the leftover |
| [`cassettes/sprocket_mistake.yml`](cassettes/sprocket_mistake.yml) | Live recording of the front-interval ask |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/11-busan-sprocket-mistake/sprocket_mistake.rb
bundle exec ruby features/11-instructions-and-history/11-busan-sprocket-mistake/sprocket_mistake_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/11-busan-sprocket-mistake/sprocket_mistake.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
