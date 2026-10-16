# Instructions and history · 04 · Kuching late-rack follow-up

The loft clerk at a Kuching white-pepper house logs which drying rack
was late on loft No. 4, then asks for that rack's come-up time without
pasting the drying card again.

**What it teaches**

- A second `ask` on the same chat sends the earlier drying card back.
- The follow-up string does not repeat the card. The answer still uses
  rack 7 and 06:40.

**Files**

| File | Role |
| --- | --- |
| [`rack_follow_up.rb`](rack_follow_up.rb) | Asks the card, then the come-up |
| [`rack_follow_up_test.rb`](rack_follow_up_test.rb) | Replays the cassette and checks both turns |
| [`cassettes/rack_follow_up.yml`](cassettes/rack_follow_up.yml) | Live recording of both asks |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/04-kuching-pepper-follow-up/rack_follow_up.rb
bundle exec ruby features/11-instructions-and-history/04-kuching-pepper-follow-up/rack_follow_up_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/04-kuching-pepper-follow-up/rack_follow_up.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
