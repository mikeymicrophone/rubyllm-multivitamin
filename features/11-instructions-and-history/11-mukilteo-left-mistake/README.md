# Instructions and history · 11 · Mukilteo range-light mistake left in

Last watch at Mukilteo Light posted the rear range as 6 seconds. The
flash card says 2.5. The clerk leaves that assistant turn on the
transcript and asks only for the front interval.

**What it teaches**

- An earlier assistant mistake can stay in `chat.messages` on purpose.
- The next request still carries `6 seconds`.
- The follow-up can still read the front interval, 4 seconds, off the
  card.

**Files**

| File | Role |
| --- | --- |
| [`left_mistake.rb`](left_mistake.rb) | Seeds the wrong rear flash, then asks the front |
| [`left_mistake_test.rb`](left_mistake_test.rb) | Replays the cassette and checks the leftover |
| [`cassettes/left_mistake.yml`](cassettes/left_mistake.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/11-mukilteo-left-mistake/left_mistake.rb
bundle exec ruby features/11-instructions-and-history/11-mukilteo-left-mistake/left_mistake_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/11-mukilteo-left-mistake/left_mistake.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
