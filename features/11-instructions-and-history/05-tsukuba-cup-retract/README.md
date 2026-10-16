# Instructions and history · 05 · Tsukuba Faraday-cup retraction

The beam clerk at KEK Tsukuba logs a fouled Faraday cup of 14 nA under
linac line DH, then assigns `chat.messages` so that pair is gone before
posting the corrected 22 nA current.

**What it teaches**

- `chat.messages` is the transcript the next request will send.
- Assigning `chat.messages = [system]` drops the retracted user and
  assistant turns.
- The next request body no longer carries `Faraday cup under the beam: 14 nA.`

**Files**

| File | Role |
| --- | --- |
| [`retracted_current.rb`](retracted_current.rb) | Logs 14 nA, trims it, posts 22 nA |
| [`retracted_current_test.rb`](retracted_current_test.rb) | Replays the cassette and checks the trim |
| [`cassettes/retracted_current.yml`](cassettes/retracted_current.yml) | Live recording of both asks |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/05-tsukuba-cup-retract/retracted_current.rb
bundle exec ruby features/11-instructions-and-history/05-tsukuba-cup-retract/retracted_current_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/05-tsukuba-cup-retract/retracted_current.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` inverted a Yes/No standing
order on 16 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
