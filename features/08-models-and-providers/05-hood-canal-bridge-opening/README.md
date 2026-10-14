# Models and providers · 05 · Hood Canal Bridge opening switch

The tender on the Hood Canal Bridge (WA-104) asks whether the posted
opening covers the tug Salish Pontoon, then switches models with
`with_model` before answering the Poulsbo school bus. The opening card
stays in the transcript.

**What it teaches**

- `with_model` on a chat that already has turns changes the model for the
  next `ask` without dropping the earlier user turn.
- The first request names `gpt-4.1-mini`. The message's `model` is the
  dated snapshot `gpt-4.1-mini-2025-04-14`.
- The second request names `gpt-4o-mini`. The message's `model` is
  `gpt-4o-mini-2024-07-18`. `chat.model.id` stays the id passed to
  `with_model`. The request still includes Salish Pontoon.

**Files**

| File | Role |
| --- | --- |
| [`opening_switch.rb`](opening_switch.rb) | Asks, switches, asks again |
| [`opening_switch_test.rb`](opening_switch_test.rb) | Replays the cassette and checks both model ids |
| [`cassettes/opening_switch.yml`](cassettes/opening_switch.yml) | Two Responses round-trips |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/08-models-and-providers/05-hood-canal-bridge-opening/opening_switch.rb
bundle exec ruby features/08-models-and-providers/05-hood-canal-bridge-opening/opening_switch_test.rb
```

Both commands replay the cassette. No API key is required. Re-record with:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/08-models-and-providers/05-hood-canal-bridge-opening/opening_switch_test.rb
```

`LIVE_PROVIDER=openrouter` records the two free slugs when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini`, then `gpt-4o-mini` after `with_model`, with
`provider: :openai`. The free OpenRouter slugs were past the daily cap on
14 October 2026. Fallback: `nvidia/nemotron-3-super-120b-a12b:free` then
`liquid/lfm-2.5-2.6b:free` via `LIVE_PROVIDER=openrouter`.
