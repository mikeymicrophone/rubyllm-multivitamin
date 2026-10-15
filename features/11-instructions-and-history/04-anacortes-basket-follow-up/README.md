# Instructions and history · 04 · Anacortes late-basket follow-up

The retort clerk at the Anacortes cannery logs which basket was late on
retort No. 4, then asks for that basket's come-up time without pasting
the cook card again.

**What it teaches**

- A second `ask` on the same chat sends the earlier cook card back.
- The follow-up string does not repeat the card. The answer still uses
  basket 7 and 06:40.

**Files**

| File | Role |
| --- | --- |
| [`basket_follow_up.rb`](basket_follow_up.rb) | Asks the card, then the come-up |
| [`basket_follow_up_test.rb`](basket_follow_up_test.rb) | Replays the cassette and checks both turns |
| [`cassettes/basket_follow_up.yml`](cassettes/basket_follow_up.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/04-anacortes-basket-follow-up/basket_follow_up.rb
bundle exec ruby features/11-instructions-and-history/04-anacortes-basket-follow-up/basket_follow_up_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/04-anacortes-basket-follow-up/basket_follow_up.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
