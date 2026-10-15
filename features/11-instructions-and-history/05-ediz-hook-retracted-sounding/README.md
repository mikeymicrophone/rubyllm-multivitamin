# Instructions and history · 05 · Ediz Hook retracted sounding

The buoy tender off Ediz Hook logs a fouled lead of 14 ft under lighted
bell buoy DH, then assigns `chat.messages` so that pair is gone before
posting the corrected 22 ft sounding.

**What it teaches**

- `chat.messages` is the transcript the next request will send.
- Assigning `chat.messages = [system]` drops the retracted user and
  assistant turns.
- The next request body no longer carries `Lead line under the buoy: 14 ft.`

**Files**

| File | Role |
| --- | --- |
| [`retracted_sounding.rb`](retracted_sounding.rb) | Logs 14 ft, trims it, posts 22 ft |
| [`retracted_sounding_test.rb`](retracted_sounding_test.rb) | Replays the cassette and checks the trim |
| [`cassettes/retracted_sounding.yml`](cassettes/retracted_sounding.yml) | Live OpenAI recording of `gpt-4.1-mini` |

**Try it**

From the repository root, with the gems installed:

```sh
bundle exec ruby features/11-instructions-and-history/05-ediz-hook-retracted-sounding/retracted_sounding.rb
bundle exec ruby features/11-instructions-and-history/05-ediz-hook-retracted-sounding/retracted_sounding_test.rb
```

Both commands replay the cassette. No API key is required.

Re-record it on OpenAI:

```sh
LIVE=1 LIVE_PROVIDER=openai OPENAI_API_KEY=... bundle exec ruby features/11-instructions-and-history/05-ediz-hook-retracted-sounding/retracted_sounding.rb
```

`LIVE_PROVIDER=openrouter` records the free slug when the daily cap
allows. Do not hand-author the cassette.

**Model**

Recorded on `gpt-4.1-mini` with `provider: :openai` after
`nvidia/nemotron-3-super-120b-a12b:free` answered `Rate limit exceeded:
free-models-per-day` on 14 October 2026. Fallback:
`liquid/lfm-2.5-2.6b:free`.
